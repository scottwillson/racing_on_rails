# frozen_string_literal: true

require "application_system_test_case"

# :stopdoc:
class FirstAidProvidersTest < ApplicationSystemTestCase
  test "first aid providers" do
    # FIXME: Punt!
    if Time.zone.today.month < 12
      login_as FactoryBot.create(:administrator)
      promoter = FactoryBot.create(:person, name: "Brad Ross")
      FactoryBot.create(:event, promoter: promoter, date: 2.days.from_now, first_aid_provider: "Megan Weaver", name: "Copperopolis")
      FactoryBot.create(:event, date: 4.days.from_now, name: "Giro di SF")
      event_3 = FactoryBot.create(:event, date: 3.days.ago, name: "San Ardo")
      FactoryBot.create(:event, date: 2.weeks.from_now, name: "Snelling")
      FactoryBot.create(:event, date: 3.weeks.from_now, name: "Berkeley Hills")

      visit "/admin/first_aid_providers"

      assert_table "events_table", 2, 4, "Copperopolis"
      assert_table "events_table", 2, 5, "Brad Ross"
      assert_table "events_table", 3, 4, "Giro di SF"
      assert !has_checked_field?("past_events")

      find(:xpath, "//table[@id='events_table']//tr[2]//td[@class='name']//div[@class='record']//div[@class='editable']").click
      within "form.editor_field" do
        fill_in "value", with: "Megan Weaver\n"
      end

      visit "/admin/first_aid_providers"
      assert_table "events_table", 2, 1, "Megan Weaver"

      if Time.zone.today.month > 1
        find("#past_events").click
        assert_table "events_table", 2, 4, "San Ardo"
        assert has_checked_field?("past_events")

        find("#past_events").click
        assert_no_text event_3.name
        assert !has_checked_field?("past_events")
      end

      assert !has_checked_field?("past_events")
      assert_table "events_table", 2, 4, "Copperopolis"
      assert_table "events_table", 3, 4, "Giro di SF"

      # Table already sorted by date ascending, so click doesn't change order
      find(:xpath, "//th[@class='date']//a").click
      assert_table "events_table", 2, 4, "Copperopolis"
      assert_table "events_table", 3, 4, "Giro di SF"

      find(:xpath, "//th[@class='date']//a").click
      assert_table "events_table", 2, 4, "Berkeley Hills"
      assert_table "events_table", 3, 4, "Snelling"

      find(:xpath, "//th[@class='date']//a").click
      assert_table "events_table", 2, 4, "Copperopolis"
      assert_table "events_table", 3, 4, "Giro di SF"
    end
  end
end
