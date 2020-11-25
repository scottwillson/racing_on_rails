# frozen_string_literal: true

require "application_system_test_case"

# :stopdoc:
class OfficialsTest < ApplicationSystemTestCase
  test "view assignments" do
    FactoryBot.create(:discipline, name: "Cyclocross")
    FactoryBot.create(:discipline, name: "Downhill")
    FactoryBot.create(:discipline, name: "Mountain Bike")
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:discipline, name: "Singlespeed")
    FactoryBot.create(:discipline, name: "Track")
    FactoryBot.create(:number_issuer, name: RacingAssociation.current.short_name)

    visit "/admin/first_aid_providers"

    visit "/people"
    assert page.has_no_selector? "export_link"

    member = FactoryBot.create(:person_with_login, official: true)
    login_as member

    visit "/admin/first_aid_providers"
    visit "/people"
    assert_download "export_link", "scoring_sheet.xls"
  end
end
