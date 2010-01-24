require "acceptance/selenium_test_case"

class PeopleTest < SeleniumTestCase
  def test_people
    login_as :administrator
    
    open '/admin/people'
    assert_text "Enter part of a person's name"
    type "name", "a"
    submit_and_wait "search_form"

    assert_element_text "warn", ""
    assert_element_text "notice", ""

    assert_table "people_table", 1, 0, "glob:Molly Cameron*"
    assert_table "people_table", 2, 0, "glob:Mark Matson*"
    assert_table "people_table", 3, 0, "glob:Candi Murray*"
    assert_table "people_table", 4, 0, "glob:Alice Pennington*"
    assert_table "people_table", 5, 0, "glob:Brad Ross*"
    assert_table "people_table", 6, 0, "glob:Ryan Weaver*"

    assert_table "people_table", 1, 1, "glob:Vanilla*"
    assert_table "people_table", 2, 1, "glob:Kona*"
    assert_table "people_table", 4, 1, "glob:Gentle Lovers*"
    assert_table "people_table", 6, 1, "glob:Gentle Lovers*"

    assert_table "people_table", 1, 2, "glob:Mollie Cameron*"
    assert_table "people_table", 2, 2, ""
    assert_table "people_table", 3, 2, ""
    assert_table "people_table", 4, 2, ""
    assert_table "people_table", 5, 2, ""
    assert_table "people_table", 6, 2, ""

    if Date.today.month < 12
      assert_table "people_table", 1, 3, "202"
      assert_table "people_table", 2, 3, "340"
      assert_table "people_table", 3, 3, ""
      assert_table "people_table", 4, 3, "230"
      assert_table "people_table", 5, 3, ""
      assert_table "people_table", 6, 3, "341"
    end

    assert_table "people_table", 1, 4, ""
    assert_table "people_table", 2, 4, ""
    assert_table "people_table", 3, 4, ""
    assert_table "people_table", 4, 4, ""
    assert_table "people_table", 5, 4, ""
    if Date.today.month < 12
      assert_table "people_table", 6, 4, "437"
    end

    @molly_id = Person.find_by_name("Molly Cameron").id
    @weaver_id = Person.find_by_name("Ryan Weaver").id
    @matson_id = Person.find_by_name("Mark Matson").id
    @matson = Person.find_by_name("Mark Matson")
    @alice_id = Person.find_by_name("Alice Pennington").id
    assert_checked "person_member_#{@molly_id}"
    assert_checked "person_member_#{@weaver_id}"
    assert_checked "person_member_#{@matson_id}"
    assert_checked "person_member_#{@alice_id}"

    click "person_#{@alice_id}_name", :wait_for => { :element => "person_#{@alice_id}_name-inplaceeditor" }

    type "css=.editor_field", "A Penn"
    submit "css=.inplaceeditor-form"
    wait_for :element => "person_#{@alice_id}_name-inplaceeditor"

    refresh
    wait_for_page
    assert_table "people_table", 4, 0, "glob:A Penn*"

    click "person_#{@weaver_id}_team_name", :wait_for => { :element => "person_#{@weaver_id}_team_name-inplaceeditor" }

    type "css=.editor_field", "River City Bicycles"
    submit "css=.inplaceeditor-form"
    wait_for :element => "person_#{@alice_id}_team_name-inplaceeditor"

    refresh
    wait_for_page
    assert_table "people_table", 6, 1, "glob:River City Bicycles*"

    click "css=a[href='/admin/people/#{@molly_id}/results']", :wait_for => :page
    assert_title "*Admin: Results: Molly Cameron"

    open '/admin/people'
    click "css=a[href='/admin/people/#{@weaver_id}/results']", :wait_for => :page
    assert_title "*Admin: Results: Ryan Weaver"

    open '/admin/people'
    click "css=a[href='/admin/people/#{@matson_id}/edit']", :wait_for => :page
    assert_title "*Admin: People: Mark Matson"
    type "person_home_phone", "411 911 1212"
    click "save", :wait_for => :page

    open '/admin/people'
    click "css=a[href='/admin/people/new']", :wait_for => :page
    assert_title "*Admin: People: New Person"

    open "/admin/people/#{@matson.id}/edit"
    assert_text "Mark Matson"
    if Date.today.month < 12
      click "destroy_number_#{@matson.race_numbers.first.id}"
      wait_for_ajax
      click "save", :wait_for => :page

      assert_no_text "error"
      assert_no_text "Unknown action"
      assert_no_text "Couldn't find RaceNumber"
    end
    
    assert_location "*/admin/people/#{@matson.id}/edit"
    
    open "/admin/people/#{Person.find_by_name("Non Results").id}/edit"
    assert_text 'Non Results'
    click 'delete', :wait_for => :page
    assert_no_text 'error'
    assert_no_text 'Unknown action'
    assert_no_text 'has no parent'

    assert_location '*/admin/people'
    type 'name', 'no results'
    submit_and_wait 'search_form'
    assert_no_text 'error'
    assert_no_text 'Non Results'
  end
  
  def test_export
    login_as :administrator

    open '/admin/people'
    assert_present 'export_button'
    assert_present 'include'
    assert_value 'include', 'members_only'
    assert_present 'format'
    assert_value 'format', 'xls'

    click 'export_button'
    wait_for_not_location "glob:*/admin/people.xls?excel_layout=xls&include=members_only"
    assert_no_text 'error'

    open '/admin/teams'
    assert_no_text 'error'
    assert_location '*/admin/teams'

    open '/admin/people'
    assert_no_text 'error'
    assert_location '*/admin/people'

    type 'name', 'tonkin'
    submit_and_wait 'search_form'
    wait_for :text =>  "Erik Tonkin"
    assert_no_text 'error'
    assert_text 'Erik Tonkin'
    assert_text 'Kona'
    if Date.today.month < 12
      assert_text '102'
    end
    assert_value 'name', 'tonkin'

    type 'include', 'all'
    type 'format', 'ppl'
    click 'export_button'
    wait_for_not_location "glob:*/admin/people.ppl?excel_layout=ppl&include=all"
    assert_no_text 'error'

    type 'include', 'members_only'
    type 'format', 'scoring_sheet'
    click 'export_button'
    wait_for_not_location "glob:*/admin/people.xls?excel_layout=scoring_sheet&include=members_only"
    assert_no_text 'error'

    type 'name', 'tonkin'
    submit_and_wait 'search_form'
    assert_no_text 'error'
    assert_text 'Erik Tonkin'
    assert_text 'Kona'
    if Date.today.month < 12
      assert_text '102'
    end
    assert_value 'name', 'tonkin'
  end
  
  def test_import
    login_as :administrator
    open '/admin/people'
    assert_present 'people_file'
  end
end
