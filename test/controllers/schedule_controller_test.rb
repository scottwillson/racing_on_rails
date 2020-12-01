# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class ScheduleControllerTest < ActionController::TestCase #:nodoc: all
  test "index" do
    FactoryBot.create(:discipline)
    FactoryBot.create(:mtb_discipline)
    FactoryBot.create(:number_issuer)

    year = 2006

    SingleDayEvent.create!(
      name: "Banana Belt I",
      city: "Hagg Lake",
      date: Date.new(year, 1, 1),
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      flyer_approved: true
    )

    SingleDayEvent.create!(
      name: "Mudslinger",
      city: "Blodgett",
      date: Date.new(year, 12, 27),
      discipline: "Mountain Bike",
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      flyer_approved: false,
      promoter: Person.create!(name: "Mike Ripley", email: "mikecycle@earthlink.net", home_phone: "203-259-8577")
    )

    SingleDayEvent.create!(postponed: true)
    get :index, params: { year: year }

    html = @response.body
    assert(html["Banana Belt I"], "'Banana Belt I' should be in HTML")
    assert(html["Mudslinger"], "'Mudslinger' should be in HTML")
    assert(html["banana_belt.html"], "Schedule should include Banana Belt flyer URL")
    assert_not(html["mud_slinger.html"], "Schedule should not include Mudslinger flyer URL")
  end

  test "index only shows visible events" do
    future_national_federation_event = FactoryBot.create(:event, sanctioned_by: "USA Cycling")

    get :index
    html = @response.body

    assert_equal(
      RacingAssociation.current.show_only_association_sanctioned_races_on_calendar?,
      !html[future_national_federation_event.name],
      "Schedule should only show events sanctioned by Association"
    )
  end

  test "index rss" do
    FactoryBot.create(:event)
    get :index, format: :rss
    assert_redirected_to schedule_path(format: :atom)
  end

  test "index atom" do
    FactoryBot.create(:event)
    get :index, format: :atom
    assert_response :success
  end

  test "index excel" do
    FactoryBot.create(:event)
    get :index, format: :xlsx
    assert_response :success
  end

  test "index excel discipline" do
    FactoryBot.create(:discipline)
    FactoryBot.create(:mtb_discipline)

    FactoryBot.create(:event, discipline: "Mountain Bike")

    get :index, params: { discipline: "mtb" }, format: :xlsx
    assert_response :success
  end

  test "index excel discipline list" do
    FactoryBot.create(:discipline)

    FactoryBot.create(:event, discipline: "Road")

    get :list, params: { discipline: "road" }, format: :xlsx
    assert_response :success
  end

  test "road index" do
    FactoryBot.create(:discipline)
    FactoryBot.create(:mtb_discipline)
    year = 2006

    SingleDayEvent.create!(
      name: "Banana Belt I",
      city: "Hagg Lake",
      date: Date.new(year, 1, 22),
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      flyer_approved: true
    )

    SingleDayEvent.new(
      name: "Mudslinger",
      city: "Blodgett",
      date: Date.new(year, 12, 27),
      discipline: "Mountain Bike",
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      flyer_approved: false,
      promoter: Person.create!(name: "Mike Ripley", email: "mikecycle@earthlink.net", home_phone: "203-259-8577")
    )

    get :index, params: { year: year, discipline: "Road" }

    html = @response.body
    assert_not(html["Mudslinger"], "Road events should not include MTB")
    assert(html["banana_belt.html"], "Schedule should include Banana Belt flyer URL")
  end

  test "mtb index" do
    FactoryBot.create(:discipline)
    FactoryBot.create(:mtb_discipline)
    FactoryBot.create(:number_issuer)
    year = 2006

    SingleDayEvent.create!(
      name: "Banana Belt I",
      city: "Hagg Lake",
      date: Date.new(year, 1, 22),
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      flyer_approved: true
    )

    SingleDayEvent.create!(
      name: "Mudslinger",
      city: "Blodgett",
      date: Date.new(year, 12, 27),
      discipline: "Mountain Bike",
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      flyer_approved: false,
      promoter: Person.create!(name: "Mike Ripley", email: "mikecycle@earthlink.net", home_phone: "203-259-8577")
    )

    get :index, params: { year: year, discipline: "Mountain Bike" }

    html = @response.body
    assert(html["Mudslinger"], "Road events should include MTB")
    assert_not(html["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end

  test "filter by sanctioning organization" do
    Timecop.freeze(2010, 2) do
      FactoryBot.create(:event, sanctioned_by: "FIAC", name: "FIAC Event")
      FactoryBot.create(:event, sanctioned_by: "UCI", name: "UCI Event")
      FactoryBot.create(:event, sanctioned_by: "CBRA", name: "CBRA Event")
      racing_association = RacingAssociation.current
      racing_association.filter_schedule_by_sanctioning_organization = true
      racing_association.show_only_association_sanctioned_races_on_calendar = false
      racing_association.save!

      get :index
      html = @response.body
      assert html["FIAC Event"], "Should include FIAC event"
      assert html["UCI Event"], "Should include UCI event"
      assert html["CBRA Event"], "Should include CBRA event"
    end
  end

  test "filter by sanctioning organization with filter" do
    Timecop.freeze(2010, 2) do
      FactoryBot.create(:event, sanctioned_by: "FIAC", name: "FIAC Event")
      FactoryBot.create(:event, sanctioned_by: "UCI", name: "UCI Event")
      FactoryBot.create(:event, sanctioned_by: "CBRA", name: "CBRA Event")
      racing_association = RacingAssociation.current
      racing_association.filter_schedule_by_sanctioning_organization = true
      racing_association.show_only_association_sanctioned_races_on_calendar = false
      racing_association.save!

      get :index, params: { sanctioning_organization: "FIAC" }
      html = @response.body
      assert html["FIAC Event"], "Should include FIAC event"
      assert_not html["UCI Event"], "Should not include UCI event"
      assert_not html["CBRA Event"], "Should not include CBRA event"
    end
  end

  test "filter by region" do
    Timecop.freeze(2010, 2) do
      racing_association = RacingAssociation.current
      racing_association.filter_schedule_by_region = true
      racing_association.save!

      wa = Region.create! name: "Washington"
      oregon = Region.create! name: "Oregon"
      Region.create! name: "Northern California"

      FactoryBot.create(:event, region: wa, name: "WA Event")
      FactoryBot.create(:event, region: oregon, name: "OR Event")

      get :index, params: { region: "washington" }
      html = @response.body
      assert html["WA Event"], "Should include Washington event"
      assert_not html["OR Event"], "Should not include Oregon event"
    end
  end

  test "index with alias" do
    FactoryBot.create(:discipline)
    FactoryBot.create(:mtb_discipline)
    FactoryBot.create(:number_issuer)

    year = 2006

    SingleDayEvent.create!(
      name: "Banana Belt I",
      city: "Hagg Lake",
      date: Date.new(year, 1, 22),
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      flyer_approved: true
    )

    SingleDayEvent.create!(
      name: "Mudslinger",
      city: "Blodgett",
      date: Date.new(year, 12, 27),
      discipline: "Mountain Bike",
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      flyer_approved: false,
      promoter: Person.create!(name: "Mike Ripley", email: "mikecycle@earthlink.net", home_phone: "203-259-8577")
    )

    get :index, params: { year: year, discipline: "mountain_bike" }

    html = @response.body
    assert(html["Mudslinger"], "mountain_bike should show MTB races")
    assert_not(html["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end

  test "list" do
    get :list
    assert_response :success
  end

  test "mtb list" do
    FactoryBot.create(:discipline)
    FactoryBot.create(:mtb_discipline)

    year = 2006

    SingleDayEvent.create!(
      name: "Banana Belt I",
      city: "Hagg Lake",
      date: Date.new(year, 1, 22),
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      flyer_approved: true
    )

    SingleDayEvent.create!(
      name: "Mudslinger",
      city: "Blodgett",
      date: Date.new(year, 12, 27),
      discipline: "Mountain Bike",
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      flyer_approved: false,
      promoter: Person.create!(name: "Mike Ripley", email: "mikecycle@earthlink.net", home_phone: "203-259-8577")
    )

    get :list, params: { year: year, discipline: "Mountain Bike" }

    html = @response.body
    assert(html["Mudslinger"], "Road events should include MTB")
    assert_not(html["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end

  test "list excel discipline" do
    FactoryBot.create(:discipline)
    FactoryBot.create(:event, discipline: "Road")

    get :list, params: { discipline: "road" }, format: :xlsx
    assert_response :success
  end

  test "index as json" do
    get :index, params: { format: "json" }
    assert_response :success
  end

  test "calendar as json" do
    get :calendar, params: { format: "json" }
    assert_response :success
  end

  test "mtb index as json" do
    FactoryBot.create(:discipline)
    FactoryBot.create(:mtb_discipline)
    SingleDayEvent.create!(
      name: "Banana Belt I",
      city: "Hagg Lake",
      date: Date.new(2006, 1, 22),
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      flyer_approved: true
    )

    SingleDayEvent.create!(
      name: "Mudslinger",
      city: "Blodgett",
      date: Date.new(2006, 12, 27),
      discipline: "Mountain Bike",
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      flyer_approved: false,
      promoter: Person.create!(name: "Mike Ripley", email: "mikecycle@earthlink.net", home_phone: "203-259-8577")
    )

    get :index, params: { year: 2006, discipline: "Mountain Bike" }, format: "json"

    json = @response.body
    assert(json["Mudslinger"], "Calendar should include MTB event")
    assert_not(json["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end

  test "mtb calendar as json" do
    FactoryBot.create(:discipline)
    FactoryBot.create(:mtb_discipline)
    SingleDayEvent.create!(
      name: "Banana Belt I",
      city: "Hagg Lake",
      date: Date.new(2006, 1, 22),
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      flyer_approved: true
    )

    SingleDayEvent.create!(
      name: "Mudslinger",
      city: "Blodgett",
      date: Date.new(2006, 12, 27),
      discipline: "Mountain Bike",
      flyer: "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      flyer_approved: false,
      promoter: Person.create!(name: "Mike Ripley", email: "mikecycle@earthlink.net", home_phone: "203-259-8577")
    )

    get :calendar, params: { year: 2006, discipline: "Mountain Bike" }, format: "json"

    json = @response.body
    assert(json["Mudslinger"], "Calendar should include MTB event")
    assert_not(json["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end
end
