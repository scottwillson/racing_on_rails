# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

# :stopdoc:
class UpcomingTest < ActiveSupport::TestCase
  test "different dates" do
    FactoryBot.create(:discipline, name: "Mountain Bike")
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:discipline, name: "Time Trial")
    FactoryBot.create(:discipline, name: "Track")

    association = RacingAssociation.current
    association.update! show_only_association_sanctioned_races_on_calendar: true

    # Tuesday
    may_day_rr = SingleDayEvent.create!(date: Date.new(2007, 5, 22), name: "May Day Road Race")
    WeeklySeries.create_for_every!("Tuesday",
                                   start_date: Date.new(2007, 4), end_date: Date.new(2007, 7), name: "Brian Abers Training", practice: true)
    # Wednesday
    lucky_lab_tt =    SingleDayEvent.create!(date: Date.new(2007, 5, 23), name: "Lucky Lab Road Race")
    not_obra =        SingleDayEvent.create!(date: Date.new(2007, 5, 23), name: "USA RR", sanctioned_by: "USA Cycling")

    # Sunday of next full week
    woodland_rr =     SingleDayEvent.create!(date: Date.new(2007, 6, 3), name: "Woodland Road Race")
    tst_rr =          SingleDayEvent.create!(date: Date.new(2007, 6, 3), name: "Tahuya-Seabeck-Tahuya")
    # Monday after that
    not_upcoming_rr = SingleDayEvent.create!(date: Date.new(2007, 6, 4), name: "Not Upcoming Road Race")
    # Monday before all other races (to test ordering)
    saltzman_hc =     SingleDayEvent.create!(date: Date.new(2007, 5, 21), name: "Saltzman Hillclimb")

    SingleDayEvent.create!(date: Date.new(2007, 5, 21), name: "canceled", canceled: true)

    # Weekly Series
    pir = WeeklySeries.create!(date: Date.new(2007, 4, 3), name: "Tuesday PIR")
    Date.new(2007, 4, 3).step(Date.new(2007, 10, 23), 7) do |date|
      pir.children.create! date: date, name: "Tue PIR #{date}"
    end
    pirs = pir.children.sort_by(&:date)

    # Way, wayback
    Timecop.freeze(Time.zone.local(2005)) do
      assert Event.upcoming.empty?, "No events in 2005"
    end

    # Wayback
    Timecop.freeze(Time.zone.local(2007, 3, 20)) do
      assert_equal_events [pirs.first], Event.upcoming
    end

    # Sunday
    Timecop.freeze(Time.zone.local(2007, 5, 20)) do
      assert_equal_events(
        [saltzman_hc, may_day_rr, lucky_lab_tt, woodland_rr, tst_rr] + pirs[7, 2],
        Event.upcoming
      )
    end

    # Monday after all events
    Timecop.freeze(Time.zone.local(2007, 10, 24)) do
      assert_equal_events([], Event.upcoming)
    end

    # Big range
    Timecop.freeze(Time.zone.local(2007, 5, 21)) do
      assert_equal_events([saltzman_hc, may_day_rr, lucky_lab_tt, woodland_rr, tst_rr, not_upcoming_rr] + pirs[7, 16], Event.upcoming(16))
    end

    # Small range
    Timecop.freeze(Time.zone.local(2007, 5, 22)) do
      assert_equal_events([may_day_rr, lucky_lab_tt] + pirs[7, 2], Event.upcoming(1))
    end

    # Include ALL events regardless of sanctioned_by
    RacingAssociation.current.show_only_association_sanctioned_races_on_calendar = false
    Timecop.freeze(Time.zone.local(2007, 5, 20)) do
      assert_equal_events([saltzman_hc, may_day_rr, lucky_lab_tt, not_obra, woodland_rr, tst_rr] + pirs[7, 2], Event.upcoming(2))
    end
  end

  test "midweek multiday event" do
    FactoryBot.create(:discipline, name: "Mountain Bike")
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:discipline, name: "Track")

    six_day = MultiDayEvent.create!(
      date: Date.new(2006, 6, 12), name: "Alpenrose Six Day", discipline: "Track", flyer_approved: true
    )
    Date.new(2006, 6, 12).step(Date.new(2006, 6, 17), 1) do |date|
      single_day_six_day = SingleDayEvent.create!(parent: six_day, date: date, name: "Alpenrose Six Day", discipline: "Track", flyer_approved: true)
      assert(single_day_six_day.valid?, "Six Day valid?")
      assert_not(single_day_six_day.new_record?, "Six Day new?")
    end
    six_day.save!
    assert(six_day.valid?, "Six Day valid?")
    assert_equal(6, six_day.children.reload.count, "Six Day events")
    assert_equal_dates(Date.new(2006, 6, 12), six_day.date, "Six Day date")
    assert_equal_dates(Date.new(2006, 6, 12), six_day.start_date, "Six Day start date")
    assert_equal_dates(Date.new(2006, 6, 17), six_day.end_date, "Six Day end date")

    Timecop.freeze(Time.zone.local(2006, 5, 28)) do
      assert_equal_events [], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(2006, 6, 3)) do
      assert_equal_events [six_day], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(2006, 6, 16)) do
      assert_equal_events [six_day], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(2006, 6, 17)) do
      assert_equal_events [six_day], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(2006, 6, 18)) do
      assert_equal_events [], Event.upcoming
    end
  end

  test "weekly series" do
    FactoryBot.create(:discipline, name: "Road")

    series = WeeklySeries.create!(
      date: Date.new(1999, 6, 8), name: "PIR"
    )

    Date.new(1999, 6, 8).step(Date.new(1999, 7, 27), 7) do |date|
      SingleDayEvent.create!(parent: series, date: date, name: "PIR #{date}")
    end

    series.reload
    assert_equal(8, series.children.reload.count, "Series events")
    assert_equal_dates(Date.new(1999, 6, 8), series.date, "Series date")
    assert_equal_dates(Date.new(1999, 6, 8), series.start_date, "Series start date")
    assert_equal_dates(Date.new(1999, 7, 27), series.end_date, "Series end date")

    # Before
    Timecop.freeze(Time.zone.local(1999, 5, 24)) do
      assert_equal_events [], Event.upcoming
    end

    # Monday
    Timecop.freeze(Time.zone.local(1999, 5, 25)) do
      assert_equal_events [series.children[0]], Event.upcoming
    end

    # Tuesday
    Timecop.freeze(Time.zone.local(1999, 6, 7)) do
      assert_equal_events series.children[0, 2], Event.upcoming
    end

    # End
    Timecop.freeze(Time.zone.local(1999, 7, 27)) do
      assert_equal_events series.children[7, 1], Event.upcoming
    end

    # Afterward
    Timecop.freeze(Time.zone.local(1999, 7, 28)) do
      assert_equal_events [], Event.upcoming
    end
  end

  test "series" do
    FactoryBot.create(:discipline, name: "Road")

    estacada_tt = Series.create!(
      date: Date.new(1999, 6, 8), name: "Estacada"
    )

    estacada_tt_1 = estacada_tt.children.create!(date: Date.new(1999, 6, 8), name: "Estacada 1")
    estacada_tt_2 = estacada_tt.children.create!(date: Date.new(1999, 6, 22), name: "Estacada 2")
    estacada_tt_3 = estacada_tt.children.create!(date: Date.new(1999, 6, 24), name: "Estacada 3")

    assert_equal(3, estacada_tt.children.reload.size, "estacada_tt events")
    assert_equal_dates(Date.new(1999, 6, 8), estacada_tt.date, "estacada_tt date")
    assert_equal_dates(Date.new(1999, 6, 8), estacada_tt.start_date, "estacada_tt start date")
    assert_equal_dates(Date.new(1999, 6, 24), estacada_tt.end_date, "estacada_tt end date")

    Timecop.freeze(Time.zone.local(1999, 1, 1)) do
      assert_equal_events [], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(1999, 6, 7)) do
      assert_equal_events [estacada_tt_1], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(1999, 6, 20)) do
      assert_equal_events [estacada_tt_2, estacada_tt_3], Event.upcoming
    end
  end

  test "mixed canceled states" do
    FactoryBot.create(:discipline, name: "Road")

    SingleDayEvent.create!(date: Date.new(2020, 5, 31), name: "single past")
    single = SingleDayEvent.create!(date: Date.new(2020, 6, 1), name: "single")
    SingleDayEvent.create!(date: Date.new(2020, 6, 16), name: "single future")
    SingleDayEvent.create!(date: Date.new(2020, 6, 1), name: "single canceled", canceled: true)

    series = Series.create!(name: "past series")
    series.children.create!(date: Date.new(2020, 5, 24))
    series.children.create!(date: Date.new(2020, 5, 31))

    series = Series.create!(name: "past and present series")
    series.children.create!(date: Date.new(2020, 5, 31))
    past_series_present_child = series.children.create!(date: Date.new(2020, 6, 2))

    series = Series.create!(name: "past and present series parent canceled", canceled: true)
    series.children.create!(date: Date.new(2020, 5, 31))
    series.children.create!(date: Date.new(2020, 6, 2))

    series = Series.create!(name: "past and present series child canceled")
    series.children.create!(date: Date.new(2020, 5, 31))
    series.children.create!(date: Date.new(2020, 6, 2), canceled: true)

    series = Series.create!(name: "present series")
    present_series_present_child = series.children.create!(date: Date.new(2020, 6, 2), name: "present series 1")
    present_series_present_child_2 = series.children.create!(date: Date.new(2020, 6, 9), name: "present series 2")

    series = Series.create!(name: "present series parent canceled", canceled: true)
    series.children.create!(date: Date.new(2020, 6, 2), name: "present parent canceled series 1")
    series.children.create!(date: Date.new(2020, 6, 9), name: "present  parent canceledseries 2")

    series = Series.create!(name: "present series child canceled")
    series.children.create!(date: Date.new(2020, 6, 2), name: "present parent canceled series 1", canceled: true)
    series.children.create!(date: Date.new(2020, 6, 9), name: "present  parent canceledseries 2", canceled: true)

    series = Series.create!(name: "present and future series")
    future_series_present_child = series.children.create!(date: Date.new(2020, 6, 2))
    series.children.create!(date: Date.new(2020, 6, 16))

    series = Series.create!(name: "present and future series parent canceled", canceled: true)
    series.children.create!(date: Date.new(2020, 6, 2))
    series.children.create!(date: Date.new(2020, 6, 16))

    series = Series.create!(name: "present and future series child canceled")
    series.children.create!(date: Date.new(2020, 6, 2), canceled: true)
    series.children.create!(date: Date.new(2020, 6, 16))

    series = Series.create!(name: "present and future series future child canceled")
    series_future_child_canceled = series.children.create!(date: Date.new(2020, 6, 2))
    series.children.create!(date: Date.new(2020, 6, 16), canceled: true)

    series = Series.create!(name: "future series")
    series.children.create!(date: Date.new(2020, 6, 16))
    series.children.create!(date: Date.new(2020, 6, 23))

    past_multi_day_event = MultiDayEvent.create!(name: "past MultiDayEvent")
    past_multi_day_event.children.create!(date: Date.new(2020, 5, 30))
    past_multi_day_event.children.create!(date: Date.new(2020, 5, 31))

    past_and_present_multi_day_event = MultiDayEvent.create!(name: "past and present MultiDayEvent")
    past_and_present_multi_day_event.children.create!(date: Date.new(2020, 5, 31))
    past_and_present_multi_day_event.children.create!(date: Date.new(2020, 6, 1))

    canceled_multi_day_event = MultiDayEvent.create!(name: "past and present MultiDayEvent parent canceled", canceled: true)
    canceled_multi_day_event.children.create!(date: Date.new(2020, 5, 31))
    canceled_multi_day_event.children.create!(date: Date.new(2020, 6, 1))

    multi_day_event_past_child_canceled = MultiDayEvent.create!(name: "past and present MultiDayEvent past child canceled")
    multi_day_event_past_child_canceled.children.create!(date: Date.new(2020, 5, 31), canceled: true)
    multi_day_event_past_child_canceled.children.create!(date: Date.new(2020, 6, 1))

    multi_day_event_present_child_canceled = MultiDayEvent.create!(name: "past and present MultiDayEvent present child canceled")
    multi_day_event_present_child_canceled.children.create!(date: Date.new(2020, 5, 31))
    multi_day_event_present_child_canceled.children.create!(date: Date.new(2020, 6, 1), canceled: true)

    multi_day_event = MultiDayEvent.create!(name: "present MultiDayEvent")
    multi_day_event.children.create!(date: Date.new(2020, 6, 6))
    multi_day_event.children.create!(date: Date.new(2020, 6, 7))

    canceled_multi_day_event = MultiDayEvent.create!(name: "present MultiDayEvent parent canceled", canceled: true)
    canceled_multi_day_event.children.create!(date: Date.new(2020, 6, 6))
    canceled_multi_day_event.children.create!(date: Date.new(2020, 6, 7))

    canceled_child_multi_day_event = MultiDayEvent.create!(name: "present MultiDayEvent child canceled")
    canceled_child_multi_day_event.children.create!(date: Date.new(2020, 6, 6))
    canceled_child_multi_day_event.children.create!(date: Date.new(2020, 6, 7), canceled: true)

    all_children_canceled_multi_day_event = MultiDayEvent.create!(name: "present MultiDayEvent all children canceled")
    all_children_canceled_multi_day_event.children.create!(date: Date.new(2020, 6, 6), canceled: true)
    all_children_canceled_multi_day_event.children.create!(date: Date.new(2020, 6, 7), canceled: true)

    present_and_future_multi_day_event = MultiDayEvent.create!(name: "present and future MultiDayEvent")
    present_and_future_multi_day_event.children.create!(date: Date.new(2020, 6, 15))
    present_and_future_multi_day_event.children.create!(date: Date.new(2020, 6, 16))

    canceled_multi_day_event = MultiDayEvent.create!(name: "present and future MultiDayEvent parent canceled", canceled: true)
    canceled_multi_day_event.children.create!(date: Date.new(2020, 6, 15))
    canceled_multi_day_event.children.create!(date: Date.new(2020, 6, 16))

    canceled_future_child_multi_day_event = MultiDayEvent.create!(name: "present and future MultiDayEvent child canceled")
    canceled_future_child_multi_day_event.children.create!(date: Date.new(2020, 6, 15))
    canceled_future_child_multi_day_event.children.create!(date: Date.new(2020, 6, 16), canceled: true)

    future_multi_day_event = MultiDayEvent.create!(name: "future MultiDayEvent")
    future_multi_day_event.children.create!(date: Date.new(2020, 6, 16))
    future_multi_day_event.children.create!(date: Date.new(2020, 6, 17))

    Timecop.freeze(Time.zone.local(2020, 6, 1)) do
      assert_equal_events [
        single,
        past_series_present_child,
        present_series_present_child,
        present_series_present_child_2,
        future_series_present_child,
        past_and_present_multi_day_event,
        multi_day_event,
        present_and_future_multi_day_event,
        series_future_child_canceled,
        multi_day_event_past_child_canceled,
        canceled_child_multi_day_event,
        canceled_future_child_multi_day_event
      ], Event.upcoming
    end
  end

  test "mixed postponed states" do
    FactoryBot.create(:discipline, name: "Road")

    SingleDayEvent.create!(date: Date.new(2020, 5, 31), name: "single past")
    single = SingleDayEvent.create!(date: Date.new(2020, 6, 1), name: "single")
    SingleDayEvent.create!(date: Date.new(2020, 6, 16), name: "single future")
    SingleDayEvent.create!(date: Date.new(2020, 6, 1), name: "single postponed", postponed: true)

    series = Series.create!(name: "past series")
    series.children.create!(date: Date.new(2020, 5, 24))
    series.children.create!(date: Date.new(2020, 5, 31))

    series = Series.create!(name: "past and present series")
    series.children.create!(date: Date.new(2020, 5, 31))
    past_series_present_child = series.children.create!(date: Date.new(2020, 6, 2))

    series = Series.create!(name: "past and present series parent postponed", postponed: true)
    series.children.create!(date: Date.new(2020, 5, 31))
    series.children.create!(date: Date.new(2020, 6, 2))

    series = Series.create!(name: "past and present series child postponed")
    series.children.create!(date: Date.new(2020, 5, 31))
    series.children.create!(date: Date.new(2020, 6, 2), postponed: true)

    series = Series.create!(name: "present series")
    present_series_present_child = series.children.create!(date: Date.new(2020, 6, 2), name: "present series 1")
    present_series_present_child_2 = series.children.create!(date: Date.new(2020, 6, 9), name: "present series 2")

    series = Series.create!(name: "present series parent postponed", postponed: true)
    series.children.create!(date: Date.new(2020, 6, 2), name: "present parent postponed series 1")
    series.children.create!(date: Date.new(2020, 6, 9), name: "present  parent postponedseries 2")

    series = Series.create!(name: "present series child postponed")
    series.children.create!(date: Date.new(2020, 6, 2), name: "present parent postponed series 1", postponed: true)
    series.children.create!(date: Date.new(2020, 6, 9), name: "present  parent postponedseries 2", postponed: true)

    series = Series.create!(name: "present and future series")
    future_series_present_child = series.children.create!(date: Date.new(2020, 6, 2))
    series.children.create!(date: Date.new(2020, 6, 16))

    series = Series.create!(name: "present and future series parent postponed", postponed: true)
    series.children.create!(date: Date.new(2020, 6, 2))
    series.children.create!(date: Date.new(2020, 6, 16))

    series = Series.create!(name: "present and future series child postponed")
    series.children.create!(date: Date.new(2020, 6, 2), postponed: true)
    series.children.create!(date: Date.new(2020, 6, 16))

    series = Series.create!(name: "present and future series future child postponed")
    series_future_child_postponed = series.children.create!(date: Date.new(2020, 6, 2))
    series.children.create!(date: Date.new(2020, 6, 16), postponed: true)

    series = Series.create!(name: "future series")
    series.children.create!(date: Date.new(2020, 6, 16))
    series.children.create!(date: Date.new(2020, 6, 23))

    past_multi_day_event = MultiDayEvent.create!(name: "past MultiDayEvent")
    past_multi_day_event.children.create!(date: Date.new(2020, 5, 30))
    past_multi_day_event.children.create!(date: Date.new(2020, 5, 31))

    past_and_present_multi_day_event = MultiDayEvent.create!(name: "past and present MultiDayEvent")
    past_and_present_multi_day_event.children.create!(date: Date.new(2020, 5, 31))
    past_and_present_multi_day_event.children.create!(date: Date.new(2020, 6, 1))

    postponed_multi_day_event = MultiDayEvent.create!(name: "past and present MultiDayEvent parent postponed", postponed: true)
    postponed_multi_day_event.children.create!(date: Date.new(2020, 5, 31))
    postponed_multi_day_event.children.create!(date: Date.new(2020, 6, 1))

    multi_day_event_past_child_postponed = MultiDayEvent.create!(name: "past and present MultiDayEvent past child postponed")
    multi_day_event_past_child_postponed.children.create!(date: Date.new(2020, 5, 31), postponed: true)
    multi_day_event_past_child_postponed.children.create!(date: Date.new(2020, 6, 1))

    multi_day_event_present_child_postponed = MultiDayEvent.create!(name: "past and present MultiDayEvent present child postponed")
    multi_day_event_present_child_postponed.children.create!(date: Date.new(2020, 5, 31))
    multi_day_event_present_child_postponed.children.create!(date: Date.new(2020, 6, 1), postponed: true)

    multi_day_event = MultiDayEvent.create!(name: "present MultiDayEvent")
    multi_day_event.children.create!(date: Date.new(2020, 6, 6))
    multi_day_event.children.create!(date: Date.new(2020, 6, 7))

    postponed_multi_day_event = MultiDayEvent.create!(name: "present MultiDayEvent parent postponed", postponed: true)
    postponed_multi_day_event.children.create!(date: Date.new(2020, 6, 6))
    postponed_multi_day_event.children.create!(date: Date.new(2020, 6, 7))

    postponed_child_multi_day_event = MultiDayEvent.create!(name: "present MultiDayEvent child postponed")
    postponed_child_multi_day_event.children.create!(date: Date.new(2020, 6, 6))
    postponed_child_multi_day_event.children.create!(date: Date.new(2020, 6, 7), postponed: true)

    all_children_postponed_multi_day_event = MultiDayEvent.create!(name: "present MultiDayEvent all children postponed")
    all_children_postponed_multi_day_event.children.create!(date: Date.new(2020, 6, 6), postponed: true)
    all_children_postponed_multi_day_event.children.create!(date: Date.new(2020, 6, 7), postponed: true)

    present_and_future_multi_day_event = MultiDayEvent.create!(name: "present and future MultiDayEvent")
    present_and_future_multi_day_event.children.create!(date: Date.new(2020, 6, 15))
    present_and_future_multi_day_event.children.create!(date: Date.new(2020, 6, 16))

    postponed_multi_day_event = MultiDayEvent.create!(name: "present and future MultiDayEvent parent postponed", postponed: true)
    postponed_multi_day_event.children.create!(date: Date.new(2020, 6, 15))
    postponed_multi_day_event.children.create!(date: Date.new(2020, 6, 16))

    postponed_future_child_multi_day_event = MultiDayEvent.create!(name: "present and future MultiDayEvent child postponed")
    postponed_future_child_multi_day_event.children.create!(date: Date.new(2020, 6, 15))
    postponed_future_child_multi_day_event.children.create!(date: Date.new(2020, 6, 16), postponed: true)

    future_multi_day_event = MultiDayEvent.create!(name: "future MultiDayEvent")
    future_multi_day_event.children.create!(date: Date.new(2020, 6, 16))
    future_multi_day_event.children.create!(date: Date.new(2020, 6, 17))

    Timecop.freeze(Time.zone.local(2020, 6, 1)) do
      assert_equal_events [
        single,
        past_series_present_child,
        present_series_present_child,
        present_series_present_child_2,
        future_series_present_child,
        past_and_present_multi_day_event,
        multi_day_event,
        present_and_future_multi_day_event,
        series_future_child_postponed,
        multi_day_event_past_child_postponed,
        postponed_child_multi_day_event,
        postponed_future_child_multi_day_event
      ], Event.upcoming
    end
  end
end
