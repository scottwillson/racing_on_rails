require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class PeopleTest < AcceptanceTest
  def test_edit
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:mtb_discipline)
    FactoryGirl.create(:number_issuer, :name => RacingAssociation.current.short_name)
    login_as FactoryGirl.create(:administrator, :name => "Candi Murray")
    molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron", :team_name => "Vanilla", :license => "202")
    molly.aliases.create!(:name => "Mollie Cameron")
    FactoryGirl.create(:result, :person => molly)
    matson = FactoryGirl.create(:person, :first_name => "Mark", :last_name => "Matson", :team_name => "Kona", :license => "340", :road_number => "765")
    alice = FactoryGirl.create(:person, :first_name => "Alice", :last_name => "Pennington", :team_name => "Gentle Lovers", :license => "230")
    brad = FactoryGirl.create(:person, :first_name => "Brad", :last_name => "Ross")
    weaver = FactoryGirl.create(:person, :first_name => "Ryan", :last_name => "Weaver", :team_name => "Gentle Lovers", :license => "341")
    
    visit '/admin/people'
    assert_page_has_content "Enter part of a person's name"
    fill_in "name", :with => "a"
    press_enter "name"
    
    assert_table("people_table", 1, 1, /^Molly Cameron/)
    assert_table("people_table", 2, 1, /^Mark Matson/)
    assert_table("people_table", 3, 1, /^Candi Murray/)
    assert_table("people_table", 4, 1, /^Alice Pennington/)
    assert_table("people_table", 5, 1, /^Brad Ross/)
    assert_table("people_table", 6, 1, /^Ryan Weaver/)
    
    assert_table("people_table", 1, 2, /^Vanilla/)
    assert_table("people_table", 2, 2, /^Kona/)
    assert_table("people_table", 4, 2, /^Gentle Lovers/)
    assert_table("people_table", 6, 2, /^Gentle Lovers/)
                
    assert_table("people_table", 1, 3, /^Mollie Cameron/)
    assert_table "people_table", 2, 3, ""
    assert_table "people_table", 3, 3, ""
    assert_table "people_table", 4, 3, ""
    assert_table "people_table", 5, 3, ""
    assert_table "people_table", 6, 3, ""
    
    assert_table "people_table", 1, 4, "202"
    assert_table "people_table", 2, 4, "340"
    assert_table "people_table", 3, 4, ""
    assert_table "people_table", 4, 4, "230"
    assert_table "people_table", 5, 4, ""
    assert_table "people_table", 6, 4, "341"
    
    assert has_checked_field?("person_member_#{molly.id}")
    assert has_checked_field?("person_member_#{weaver.id}")
    assert has_checked_field?("person_member_#{matson.id}")
    assert has_checked_field?("person_member_#{alice.id}")
    
    fill_in_inline "#person_#{alice.id}_name", :with => "A Penn"
    visit "/admin/people"
    assert_table("people_table", 4, 1, /^A Penn/)
    
    fill_in_inline "#person_#{weaver.id}_team_name", :with => "River City Bicycles"
    visit "/admin/people"
    assert_table("people_table", 6, 2, /^River City Bicycles/)
    
    click_link "#{molly.id}_results"
    assert_match(/Admin: Results: Molly Cameron/, find("title").text)
    
    visit "/admin/people"
    click_link "#{weaver.id}_results"
    assert_match(/Admin: Results: Ryan Weaver$/, find("title").text)
    
    visit "/admin/people"
    click_link "edit_#{matson.id}"
    assert_match(/Admin: People: Mark Matson$/, find("title").text)
    fill_in "person_home_phone", :with => "411 911 1212"
    click_button "Save"
    
    first("a[href='/people/#{matson.id}/versions']").click
    
    visit '/admin/people'
    click_link "new_person"
    assert_match(/Admin: People: New Person/, find("title").text)
    
    matson.race_numbers.create!(:value => "878", :year => 2009)
    visit "/admin/people/#{matson.id}/edit"
    assert_page_has_content "Mark Matson"
    if Time.zone.today.month < 12
      click_link "destroy_number_#{matson.race_numbers.first.id}"
      assert_page_has_no_content "input.number[value='765']"
      
      click_button "Save"
    
      assert_page_has_no_content "error"
      assert_page_has_no_content "Unknown action"
      assert_page_has_no_content "Couldn't find RaceNumber"
    end

    assert !page.has_css?("input.number[value='878']")
    select "2009", :from => "number_year"
    assert page.has_css?("input.number[value='878']")
    
    visit "/admin/people/#{brad.id}/edit"
    assert_page_has_content 'Ross'
    click_link "delete"
    assert_page_has_no_content 'error'
    assert_page_has_no_content 'Unknown action'
    assert_page_has_no_content 'has no parent'
    
    fill_in "name", :with => "Brad"
    press_enter "name"
    assert_page_has_no_content "Ross"

    visit "/admin/people"
    fill_in "name", :with => "a"
    press_enter "name"
    
    find("#person_#{alice.id}").drag_to(find("#person_#{molly.id}"))
    wait_for_page_content "Merged A Penn into Molly Cameron"
    assert page.has_selector?("#notice", :visible => true)
    assert page.has_selector?("#warn", :visible => false)
    assert !page.has_selector?("#info")
    assert !Person.exists?(alice.id), "Alice should be merged"
    assert Person.exists?(molly.id), "Molly still exist after merge"
  end

  def test_merge_confirm
    login_as FactoryGirl.create(:administrator, :name => "Candi Murray")
    FactoryGirl.create(:person, :name => "Molly Cameron")
    FactoryGirl.create(:person, :name => "Mark Matson")

    visit "/admin/people"
    fill_in "name", :with => "a"
    press_enter "name"
    
    assert_table("people_table", 1, 1, /^Molly Cameron/)
    assert_table("people_table", 2, 1, /^Mark Matson/)
    
    molly = Person.find_by_name("Molly Cameron")
    matson = Person.find_by_name("Mark Matson")

    fill_in_inline "#person_#{matson.id}_name", :with => "Molly Cameron"

    find(".ui-dialog-buttonset button:last-child").click
    
    assert Person.exists?(molly.id), "Should not have merged Molly"
    assert Person.exists?(matson.id), "Should not have merged Matson"
    assert !molly.aliases(true).map(&:name).include?("Mark Matson"), "Should not add Matson alias"

    visit "/admin/people"
    press_enter "name"
    assert_table("people_table", 1, 1, /^Molly Cameron/)
    assert_table("people_table", 2, 1, /^Mark Matson/)

    fill_in_inline "#person_#{matson.id}_name", :with => "Molly Cameron"
    find(".ui-dialog-buttonset button:first-child").click
    
    assert_page_has_content "Merged Mark Matson into Molly Cameron"
    assert Person.exists?(molly.id), "Should not have merged Molly"
    assert !Person.exists?(matson.id), "Should have merged Matson"
    assert molly.aliases(true).map(&:name).include?("Mark Matson"), "Should add Matson alias"
  end

  def test_export
    FactoryGirl.create(:discipline, :name => "Cyclocross")
    FactoryGirl.create(:discipline, :name => "Downhill")
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Singlespeed")
    FactoryGirl.create(:discipline, :name => "Track")
    FactoryGirl.create(:number_issuer, :name => RacingAssociation.current.short_name)
    
    FactoryGirl.create(:person, :name => "Erik Tonkin", :team_name => "Kona", :license => "102")

    login_as FactoryGirl.create(:administrator)

    visit '/admin/people'
    assert page.has_selector? '#export_button'
    assert page.has_selector? '#include'
    assert page.has_field? 'include', :with => 'members_only'
    assert page.has_field? 'format', :with => 'xls'

    click_button "Export"
    wait_for_download "people_#{RacingAssociation.current.effective_year}_1_1.xls"

    visit '/admin/teams'

    visit '/admin/people'

    fill_in "name", :with => "tonkin"
    press_enter "name"
    assert_page_has_content 'Erik Tonkin'
    assert_page_has_content 'Kona'
    if Time.zone.today.month < 12
      assert_page_has_content '102'
    end
    assert page.has_field? 'name', :with => 'tonkin'

    select "All", :from => "include"
    select "FinishLynx", :from => "format"
    click_button "Export"
    wait_for_download "lynx.ppl"

    visit '/admin/people'
    select "Current members only", :with => "include"
    select "Scoring sheet", :with => "format"
    remove_download "scoring_sheet.xls"
    click_button "Export"
    wait_for_download "scoring_sheet.xls"

    fill_in 'name', :with => 'tonkin'
    press_enter "name"
    assert_page_has_content 'Erik Tonkin'
    assert_page_has_content 'Kona'
    if Time.zone.today.month < 12
      assert_page_has_content '102'
    end
    assert page.has_field? 'name', :with => 'tonkin'
  end
  
  def test_import
    login_as FactoryGirl.create(:administrator)
    visit '/admin/people'
    attach_file 'people_file', "#{Rails.root}/test/files/membership/database.xls"
  end
end
