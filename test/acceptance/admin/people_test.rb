require "acceptance/webdriver_test_case"

# :stopdoc:
class PeopleTest < WebDriverTestCase
  def test_people
    login_as :administrator
    
    open '/admin/people'
    assert_page_source "Enter part of a person's name"
    type "a", "name"
    submit "search_form"

    assert_text "", "warn"
    assert_text "", "notice"

    assert_table("people_table", 1, 0, /^Molly Cameron/)
    assert_table("people_table", 2, 0, /^Mark Matson/)
    assert_table("people_table", 3, 0, /^Candi Murray/)
    assert_table("people_table", 4, 0, /^Alice Pennington/)
    assert_table("people_table", 5, 0, /^Brad Ross/)
    assert_table("people_table", 6, 0, /^Ryan Weaver/)

    assert_table("people_table", 1, 1, /^Vanilla/)
    assert_table("people_table", 2, 1, /^Kona/)
    assert_table("people_table", 4, 1, /^Gentle Lovers/)
    assert_table("people_table", 6, 1, /^Gentle Lovers/)
                
    assert_table("people_table", 1, 2, /^Mollie Cameron/)
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

    click "person_#{@alice_id}_name"
    wait_for_element "person_#{@alice_id}_name-inplaceeditor"

    type "A Penn", :class => "editor_field"
    type :return, { :class_name => "editor_field" }, false
    wait_for_no_element "person_#{@alice_id}_name-inplaceeditor"

    refresh
    wait_for_element "people_table"
    assert_table("people_table", 4, 0, /^A Penn/)

    click "person_#{@weaver_id}_team_name"
    wait_for_no_element "person_#{@weaver_id}_name-inplaceeditor"

    type "River City Bicycles", :class => "editor_field"
    type :return, { :class_name => "editor_field" }, false
    wait_for_no_element "person_#{@alice_id}_name-inplaceeditor"

    refresh
    wait_for_element "people_table"
    assert_table("people_table", 6, 1, /^River City Bicycles/)

    click "#{@molly_id}_results"
    wait_for_element "person_#{@molly_id}_table"
    assert_title(/Admin: Results: Molly Cameron$/)

    open "/admin/people"
    click "#{@weaver_id}_results"
    assert_title(/Admin: Results: Ryan Weaver$/)

    open "/admin/people"
    click "edit_#{@matson_id}"
    assert_title(/Admin: People: Mark Matson$/)
    type "411 911 1212", "person_home_phone"
    click "save"
    
    click :css => "a[href='/people/#{@matson_id}/versions']"

    open '/admin/people'
    click "new_person"
    assert_title(/Admin: People: New Person/)

    open "/admin/people/#{@matson.id}/edit"
    assert_page_source "Mark Matson"
    if Date.today.month < 12
      click "destroy_number_#{@matson.race_numbers.first.id}"
      wait_for_no_element :css => "input.number[value='340']"
      
      click "save"

      assert_not_in_page_source "error"
      assert_not_in_page_source "Unknown action"
      assert_not_in_page_source "Couldn't find RaceNumber"
    end
    
    assert_current_url(/admin\/people\/#{@matson.id}\/edit/)
    
    open "/admin/people/#{Person.find_by_name("Non Results").id}/edit"
    assert_page_source 'Non Results'
    click "delete"
    assert_not_in_page_source 'error'
    assert_not_in_page_source 'Unknown action'
    assert_not_in_page_source 'has no parent'

    assert_current_url(/\/admin\/people/)
    type "no results", "name"
    submit "search_form"
    assert_not_in_page_source "Non Results"
  end
  
  def test_export
    login_as :administrator

    open '/admin/people'
    assert_element 'export_button'
    assert_element 'include'
    assert_value 'members_only', 'include'
    assert_element 'format'
    assert_value 'xls', 'format'

    remove_download "people_2011_1_1.xls"
    click 'export_button'
    wait_for_not_current_url(/\/admin\/people.xls\?excel_layout=xls&include=members_only/)
    wait_for_download "people_2011_1_1.xls"
    assert_no_errors

    open '/admin/teams'
    assert_current_url(/\/admin\/teams/)

    open '/admin/people'
    assert_current_url(/\/admin\/people/)

    type "tonkin", "name"
    type :return, { :name => "name" }, false
    assert_not_in_page_source 'error'
    assert_page_source 'Erik Tonkin'
    assert_page_source 'Kona'
    if Date.today.month < 12
      assert_page_source '102'
    end
    assert_value 'tonkin', "name"

    select_option "all", "include"
    select_option "ppl", "format"
    remove_download "lynx.ppl"
    click 'export_button'
    wait_for_not_current_url(/\/admin\/people.ppl\?excel_layout=ppl&include=all/)
    wait_for_download "lynx.ppl"
    assert_no_errors

    select_option "members_only", "include"
    select_option "scoring_sheet", "format"
    remove_download "scoring_sheet.xls"
    click 'export_button'
    wait_for_not_current_url(/\/admin\/people.xls\?excel_layout=scoring_sheet&include=members_only/)
    wait_for_download "scoring_sheet.xls"
    assert_no_errors

    type 'tonkin', 'name'
    type :return, { :name => "name" }, false
    wait_for_element "people_table"
    assert_page_source 'Erik Tonkin'
    assert_page_source 'Kona'
    if Date.today.month < 12
      assert_page_source '102'
    end
    assert_value 'tonkin', "name"
  end
  
  def test_import
    login_as :administrator
    open '/admin/people'
    assert_element 'people_file'
  end
end
