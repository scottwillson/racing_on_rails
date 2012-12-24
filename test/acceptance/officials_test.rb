require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class OfficialsTest < AcceptanceTest
  def test_view_assignments
    javascript!

    FactoryGirl.create(:discipline, :name => "Cyclocross")
    FactoryGirl.create(:discipline, :name => "Downhill")
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Singlespeed")
    FactoryGirl.create(:discipline, :name => "Track")
    FactoryGirl.create(:number_issuer, :name => RacingAssociation.current.short_name)

    visit "/admin/first_aid_providers"

    visit "/people"
    assert page.has_no_selector? "export_link"
    
    login_as FactoryGirl.create(:administrator)
    member = FactoryGirl.create(:person_with_login)
    visit "/admin/people/#{member.id}/edit"
    check "person_official"
    click_button "Save"
    
    logout
    login_as member
    visit "/admin/first_aid_providers"

    visit "/people"
    remove_download "scoring_sheet.xls"
    click_link "export_link"
    wait_for_download "scoring_sheet.xls"
  end
end
