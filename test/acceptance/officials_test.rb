require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class OfficialsTest < AcceptanceTest
  test "view assignments" do
    javascript!

    FactoryGirl.create(:discipline, name: "Cyclocross")
    FactoryGirl.create(:discipline, name: "Downhill")
    FactoryGirl.create(:discipline, name: "Mountain Bike")
    FactoryGirl.create(:discipline, name: "Road")
    FactoryGirl.create(:discipline, name: "Singlespeed")
    FactoryGirl.create(:discipline, name: "Track")
    FactoryGirl.create(:number_issuer, name: RacingAssociation.current.short_name)

    visit "/admin/first_aid_providers"

    visit "/people"
    assert page.has_no_selector? "export_link"

    member = FactoryGirl.create(:person_with_login, official: true)
    login_as member

    visit "/admin/first_aid_providers"

    if RacingAssociation.current.ssl?
      visit "https://localhost/people"
    else
      visit "/people"
    end

    assert_download "export_link", "scoring_sheet.xls"
  end
end
