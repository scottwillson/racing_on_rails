# frozen_string_literal: true

require "test_helper"

# :stopdoc:
module Admin
  module Events
    class UploadTest < ActionController::TestCase
      tests Admin::EventsController

      def setup
        super
        create_administrator_session
        use_ssl

        FactoryBot.create(:discipline, name: "Cyclocross")
        FactoryBot.create(:discipline, name: "Downhill")
        FactoryBot.create(:discipline, name: "Mountain Bike")
        FactoryBot.create(:discipline, name: "Road")
        FactoryBot.create(:discipline, name: "Singlespeed")
        FactoryBot.create(:discipline, name: "Track")
        FactoryBot.create(:number_issuer)
      end

      test "upload" do
        mt_hood_1 = FactoryBot.create(:stage_race)
        assert(mt_hood_1.races.empty?, "Should have no races before import")

        post :upload, params: { id: mt_hood_1.to_param,
                      results_file: fixture_file_upload("results/pir_2006_format.xlsx", "application/vnd.ms-excel", :binary) }

        assert(flash[:warn].blank?, "flash[:warn] should be empty,  but was: #{flash[:warn]}")
        assert_redirected_to edit_admin_event_path(mt_hood_1)
        assert_not_nil flash[:notice]
        assert(!mt_hood_1.races.reload.empty?, "Should have races after upload attempt")
      end

      test "upload usac" do
        RacingAssociation.current.update! usac_results_format: true
        mt_hood_1 = FactoryBot.create(:stage_race)

        post :upload, params: { id: mt_hood_1.to_param,
                      results_file: fixture_file_upload("results/tt_usac.xls", "application/vnd.ms-excel", :binary) }

        assert flash[:warn].blank?, "flash[:warn] should be empty, but was: #{flash[:warn]}"
        assert_redirected_to edit_admin_event_path(mt_hood_1)
        assert_not_nil flash[:notice]
        assert mt_hood_1.races.reload.present?, "Should have races after upload"
      end

      test "upload custom columns" do
        mt_hood_1 = FactoryBot.create(:stage_race)
        assert(mt_hood_1.races.empty?, "Should have no races before import")

        post :upload, params: { id: mt_hood_1.to_param,
                      results_file: fixture_file_upload("results/custom_columns.xls", "application/vnd.ms-excel", :binary) }
        assert_redirected_to edit_admin_event_path(mt_hood_1)

        assert_response :redirect
        assert_not_nil flash[:notice]
        assert(flash[:warn].blank?)
        assert(!mt_hood_1.races.reload.empty?, "Should have races after upload attempt")
      end

      test "upload with many warnings" do
        event = FactoryBot.create(:event)

        post :upload, params: { id: event.to_param, results_file: fixture_file_upload("results/ttt.xls", "application/vnd.ms-excel", :binary) }

        assert_redirected_to edit_admin_event_path(event)
        assert flash[:notice].nil? || flash[:notice].size < 1024, "flash[:notice] is too big: #{flash[:notice].size} characters"
        assert event.any_results?, "Should have results after upload"
      end

      test "upload dupe people" do
        # Two people with different name, same numbers
        # Excel file has Greg Rodgers with no number
        Person.create(name: "Greg Rodgers", road_number: "404")
        Person.create(name: "Greg Rodgers", road_number: "500")

        mt_hood_1 = FactoryBot.create(:stage_race)
        assert(mt_hood_1.races.reload.empty?, "Should have no races before import")

        file = fixture_file_upload("results/dupe_people.xls", "application/vnd.ms-excel", :binary)
        post :upload, params: { id: mt_hood_1.to_param, results_file: file }

        assert_response :redirect

        # Dupe people used to be allowed, and this would have been an error
        assert(!mt_hood_1.races.reload.empty?, "Should have races after importing dupe people")
        assert(flash[:warn].blank?)
      end

      test "upload schedule" do
        post :upload_schedule, params: { schedule_file: fixture_file_upload("schedule/excel.xls", "application/vnd.ms-excel", :binary) }

        assert(flash[:warn].blank?, "flash[:warn] should be empty,  but was: #{flash[:warn]}")
        assert_response :redirect
        assert_redirected_to(admin_events_path)
        assert_not_nil flash[:notice]

        after_import_after_schedule_start_date = Event.where("date > ?", Date.new(2005)).count
        assert_equal(76, after_import_after_schedule_start_date, "2005 events count after import")
        after_import_all = Event.count
        assert_equal(76, after_import_all, "All events count after import")
      end

      test "upload bad xls format" do
        mt_hood_1 = FactoryBot.create(:stage_race)

        Results::ResultsFile.any_instance.expects(:import).raises(Ole::Storage::FormatError, "OLE2 signature is invalid")

        post :upload, params: { id: mt_hood_1.to_param,
                      results_file: fixture_file_upload("results/pir_2006_format.xlsx", "application/vnd.ms-excel", :binary) }

        assert(flash[:warn].present?, "should have flash[:warn]")
        assert_response :success
        assert(mt_hood_1.races.reload.empty?, "Should have no races after failed upload attempt")
      end
    end
  end
end
