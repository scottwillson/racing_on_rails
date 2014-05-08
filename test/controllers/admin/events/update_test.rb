require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  module Events
    class UpdateControllerTest < ActionController::TestCase
      tests Admin::EventsController

      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::CaptureHelper

      def setup
        super
        create_administrator_session
        use_ssl
      end

      test "update child event" do
        event = FactoryGirl.create(:event)

        assert_not_equal('Banana Belt One', event.name, 'name')
        assert_not_equal(2, event.bar_points, 'bar_points')
        assert_not_equal('Cyclocross', event.discipline, 'discipline')

        post(:update,
             "commit"=>"Save",
             id: event.to_param,
             "event"=>{"bar_points"=>"2", "name"=>"Banana Belt One", "discipline"=>"Cyclocross"}
        )
        assert_redirected_to edit_admin_event_path(event)

        event.reload
        assert_equal('Banana Belt One', event.name, 'name')
        assert_equal('Cyclocross', event.discipline, 'discipline')
        assert_equal(2, event.bar_points, 'bar_points')
      end

      test "update nil disciplines" do
        event = FactoryGirl.create(:series_event)
        event.update(discipline: nil)
        assert_nil(event[:discipline], 'discipline')
        assert_equal('Road', event.parent.discipline, 'Parent event discipline')

        post(:update,
             "commit"=>"Save",
             id: event.to_param,
             "event"=>{"bar_points"=>"2", "name"=>"Banana Belt One", "discipline"=>"Road"}
        )
        assert_redirected_to edit_admin_event_path(event)

        event.reload
        assert_equal("Road", event[:discipline], 'discipline')
      end

      test "update discipline same as parent child events" do
        FactoryGirl.create(:discipline)
        event = FactoryGirl.create(:series_event)
        assert_equal('Road', event[:discipline], 'discipline')
        assert_equal('Road', event.discipline, 'Parent event discipline')

        post(:update,
             "commit"=>"Save",
             id: event.to_param,
             "event"=>{"bar_points"=>"2", "name"=>"Banana Belt One", "discipline"=>"Road"}
        )
        assert_redirected_to edit_admin_event_path(event)

        event.reload
        assert_equal("Road", event[:discipline], 'discipline')
      end

      test "update existing combined results" do
        FactoryGirl.create(:discipline)
        FactoryGirl.create(:discipline, name: "Mountain Bike")
        FactoryGirl.create(:discipline, name: "Time Trial")
        source_event = FactoryGirl.create(:time_trial_event)
        FactoryGirl.create(:result, event: source_event)
        source_event.bar_points = 2
        source_event.save!
        event = CombinedTimeTrialResults.create!(parent: source_event)

        post(:update, "id" => event.id,
                      "event"=>{ "auto_combined_results"=>"1",
                                      "name"=>"Portland MTB Short Track Series",
                                      "bar_points"=>"0",
                                      "ironman"=>"1",
                                      "discipline"=>"Mountain Bike"})

        assert_nil(flash[:warn], "flash[:warn] should be empty, but was: #{flash[:empty]}")
        assert_redirected_to edit_admin_event_path(event)
      end

      test "update event" do
        event = FactoryGirl.create(:event)
        brad_ross = FactoryGirl.create(:person, first_name: "Brad", last_name: "Ross")

        assert_not_equal('Banana Belt One', event.name, 'name')
        assert_not_equal('Forest Grove', event.city, 'city')
        assert_not_equal('Geoff Mitchem', event.promoter_name, 'promoter_name')
        assert_not_equal(Date.new(2006, 03, 12), event.date, 'date')
        assert_not_equal('../../flyers/2006/event.html', event.flyer, 'flyer')
        assert_not_equal('UCI', event.sanctioned_by, 'sanctioned_by')
        assert_not_equal(true, event.flyer_approved, 'flyer_approved')
        assert_not_equal('503-233-3636', event.promoter.home_phone, 'promoter_phone')
        assert_not_equal('JMitchem@ffadesign.com', event.promoter.email, 'promoter.email')
        assert_not_equal('Track', event.discipline, 'discipline')
        assert_not_equal(true, event.cancelled, 'cancelled')
        assert_not_equal('WA', event.state, 'state')
        norba = NumberIssuer.create!(name: 'NORBA')
        assert_not_equal(norba, event.number_issuer, 'number_issuer')

        post(:update,
             "commit"=>"Save",
             id: event.to_param,
             "event"=>{"city"=>"Forest Grove", "name"=>"Banana Belt One","date"=>"2006-03-12",
                       "flyer"=>"http://#{RacingAssociation.current.static_host}/flyers/2006/event.html", "sanctioned_by"=>"UCI", "flyer_approved"=>"1",
                       "discipline"=>"Track", "cancelled"=>"1", "state"=>"WA",
                      "promoter_id" => brad_ross.to_param, 'number_issuer_id' => norba.to_param}
        )
        assert_redirected_to edit_admin_event_path(event)

        event.reload
        assert_equal('Banana Belt One', event.name, 'name')
        assert_equal('Forest Grove', event.city, 'city')
        assert_equal(Date.new(2006, 03, 12), event.date, 'date')
        assert_equal("http://#{RacingAssociation.current.static_host}/flyers/2006/event.html", event.flyer, 'flyer')
        assert_equal('UCI', event.sanctioned_by, 'sanctioned_by')
        assert_equal(true, event.flyer_approved, 'flyer_approved')
        assert_equal('Track', event.discipline, 'discipline')
        assert_equal(true, event.cancelled, 'cancelled')
        assert_equal('WA', event.state, 'state')
        assert_equal('Brad Ross', event.promoter_name, 'promoter_name')
        assert_nil(event.promoter.home_phone, 'promoter_phone')
        assert_nil(event.promoter.email, 'promoter_email')
        assert_equal(norba, event.number_issuer, 'number_issuer')
      end

      test "update single day to multi day" do
        number_issuer = FactoryGirl.create(:number_issuer)
        FactoryGirl.create(:number_issuer, name: "Stage Race")
        for type in [MultiDayEvent, Series, WeeklySeries]
          event = FactoryGirl.create(:event)

          post(:update,
               "commit"=>"Save",
               id: event.to_param,
               "event"=>{"city"=>"Forest Grove", "name"=>"Banana Belt One","date"=>"2006-03-12",
                         "flyer"=>"../../flyers/2006/event.html", "sanctioned_by"=>"UCI",
                         "flyer_approved"=>"1",
                         "discipline"=>"Track", "cancelled"=>"1", "state"=>"OR",
                         "promoter_id" => event.promoter.to_param,
                         'number_issuer_id' => number_issuer.to_param,
                         'type' => type}
          )
          assert_redirected_to edit_admin_event_path(event)
          event = Event.find(event.id)
          assert(event.is_a?(type), "#{event.name} should be a #{type}")
        end
      end

      test "update to event" do
        FactoryGirl.create(:number_issuer)
        number_issuer = FactoryGirl.create(:number_issuer, name: "Stage Race")

        [ MultiDayEvent, Series, WeeklySeries, SingleDayEvent ].each do |type|
          event = type.create!

          post(:update,
               "commit"=>"Save",
               id: event.to_param,
               "event"=>{"city"=>"Forest Grove", "name"=>"Banana Belt One","date"=>"2006-03-12",
                         "flyer"=>"../../flyers/2006/event.html", "sanctioned_by"=>"UCI",
                         "flyer_approved"=>"1",
                         "discipline"=>"Track", "cancelled"=>"1", "state"=>"OR",
                         "promoter_id" => event.promoter.to_param,
                         'number_issuer_id' => number_issuer.to_param,
                         'type' => "Event" }
          )
          assert_redirected_to edit_admin_event_path(event)
          event = Event.find(event.id)
          assert_equal Event, event.class, "#{event.name} should be an Event, but is a #{event.class}"
        end
      end

      test "update multi day to single day" do
        event = FactoryGirl.create(:stage_race)
        original_attributes = event.attributes.clone

        post(:update,
             "commit"=>"Save",
             id: event.to_param,
             "event"=>{"city"=>event.city, "name"=>"Mt. Hood One Day",
                       "flyer"=>event.flyer, "sanctioned_by"=>event.sanctioned_by, "flyer_approved"=> event.flyer_approved,
                       "discipline"=>event.discipline, "cancelled"=>event.cancelled, "state"=>event.state,
                      'promoter_id' => event.promoter_id, 'number_issuer_id' => event.number_issuer_id, 'type' => 'SingleDayEvent'}
        )
        event = assigns(:event)
        assert_not_nil(event, "@event")
        assert event.errors.empty?, event.errors.full_messages.join
        assert_redirected_to edit_admin_event_path(event)
        assert(event.is_a?(SingleDayEvent), "Mt Hood should be a SingleDayEvent")

        assert_equal("Mt. Hood One Day", event.name, 'name')
        assert_equal(original_attributes["date"].to_date, event.date, 'date')
        assert_equal(original_attributes["flyer"], event.flyer, 'flyer')
        assert_equal(original_attributes["sanctioned_by"], event.sanctioned_by, 'sanctioned_by')
        assert_equal(original_attributes["flyer_approved"], event.flyer_approved, 'flyer_approved')
        assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
        assert_equal(original_attributes["cancelled"], event.cancelled, 'cancelled')
        assert_equal(original_attributes["state"], event.state, 'state')
        assert_equal(original_attributes["promoter_id"], event.promoter_id, 'promoter_id')
        assert_equal(original_attributes["number_issuer_id"], event.number_issuer_id, 'number_issuer_id')
        assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
      end

      # MultiDayEvent -> Series
      test "update multi day to series" do
        event = FactoryGirl.create(:stage_race)
        original_attributes = event.attributes.clone

        put(:update,
             "commit"=>"Save",
             id: event.to_param,
             "event"=>{"city"=>event.city, "name"=>"Mt. Hood Series","date"=>event.date.to_date,
                       "flyer"=>event.flyer, "sanctioned_by"=>event.sanctioned_by, "flyer_approved"=> event.flyer_approved,
                       "discipline"=>event.discipline, "cancelled"=>event.cancelled, "state"=>event.state,
                      'promoter_id' => event.promoter_id, 'number_issuer_id' => event.number_issuer_id, 'type' => 'Series'}
        )
        assert_redirected_to edit_admin_event_path(event)
        event = Event.find(event.id)
        assert(event.is_a?(Series), "Mt Hood should be a Series, but is a #{event.class}")

        assert_equal("Mt. Hood Series", event.name, 'name')
        assert_equal(original_attributes["date"].to_date, event.date, 'date')
        assert_equal(original_attributes["flyer"], event.flyer, 'flyer')
        assert_equal(original_attributes["sanctioned_by"], event.sanctioned_by, 'sanctioned_by')
        assert_equal(original_attributes["flyer_approved"], event.flyer_approved, 'flyer_approved')
        assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
        assert_equal(original_attributes["cancelled"], event.cancelled, 'cancelled')
        assert_equal(original_attributes["state"], event.state, 'state')
        assert_equal(original_attributes["promoter_id"], event.promoter_id, 'promoter_id')
        assert_equal(original_attributes["number_issuer_id"], event.number_issuer_id, 'number_issuer_id')
        assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
      end
    end
  end
end

