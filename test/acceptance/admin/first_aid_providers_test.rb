require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class FirstAidProvidersTest < AcceptanceTest
  setup :javascript!

  def test_first_aid_providers
    # FIXME Punt!
    if Time.zone.today.month < 12
      login_as FactoryGirl.create(:administrator)
      promoter = FactoryGirl.create(:person, :name => "Brad Ross")
      event_1 = FactoryGirl.create(:event, :promoter => promoter, :date => 2.days.from_now, :first_aid_provider => "Megan Weaver", :name => "Copperopolis")
      event_2 = FactoryGirl.create(:event, :date => 4.days.from_now, :name => "Giro di SF")
      event_3 = FactoryGirl.create(:event, :date => 3.days.ago, :name => "San Ardo")
      FactoryGirl.create(:event, :date => 2.weeks.from_now, :name => "Snelling")
      FactoryGirl.create(:event, :date => 3.weeks.from_now, :name => "Berkeley Hills")

      visit "/admin/first_aid_providers"

      assert_table "events_table", 2, 4, "Copperopolis"
      assert_table "events_table", 2, 5, "Brad Ross"
      assert_table "events_table", 3, 4, "Giro di SF"
      assert !has_checked_field?("past_events")

      find(:xpath, "//table[@id='events_table']//tr[2]//td[@class='name']//div[@class='record']//div[@class='editable']").click
      within "form.editor_field" do
        fill_in "value", :with => "Megan Weaver"
        press_return "value"
      end

      visit "/admin/first_aid_providers"
      assert_table "events_table", 2, 1, "Megan Weaver"

      if Time.zone.today.month > 1
        find("#past_events").click
        assert_table "events_table", 2, 4, "San Ardo"
        assert has_checked_field?("past_events")

        find("#past_events").click
        assert_page_has_no_content event_3.name
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
