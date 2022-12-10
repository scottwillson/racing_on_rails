# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::BarTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "#calculate!" do
    Timecop.freeze(2019, 1) do
      calculation = Calculations::V3::Calculation.create!(
        disciplines: [Discipline[:road]],
        field_size_bonus: true,
        members_only: true,
        name: "Road BAR",
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )

      category_3_men = ::Category.find_or_create_by(name: "Category 3 Men")
      calculation.categories << ::Category.find_or_create_by(name: "Senior Men")
      calculation.categories << ::Category.find_or_create_by(name: "Junior Men")
      calculation.categories << category_3_men

      event = FactoryBot.create(:event, date: Time.zone.local(2019, 3, 31))
      calculation.calculations_events.create!(event: event, multiplier: 2)
      source_race = event.races.create!(category: category_3_men)
      person = FactoryBot.create(:person)
      source_race.results.create!(place: 7, person: person)

      person = FactoryBot.create(:past_member)
      source_race.results.create!(place: 3, person: person)

      calculation.calculate!

      bar = calculation.reload.event

      assert_equal "Road BAR", bar.name
      assert_equal 3, bar.races.size
      race = bar.races.detect { |r| r.category == category_3_men }
      assert_not_nil race

      results = race.results.sort
      assert_equal 2, results.size

      assert_equal 1, results.first.source_results.size
      assert_nil results.first.rejection_reason
      assert_equal 18, results.first.points

      assert_equal 0, results.second.points
      assert 0, results.second.rejected?
      assert_equal "members_only", results.second.rejection_reason

      # Should not count self
      calculation.calculate!

      bar = calculation.reload.event
      assert_equal "Road BAR", bar.name
      assert_equal 3, bar.races.size
      race = bar.races.detect { |r| r.category == category_3_men }
      assert_not_nil race

      results = race.results.sort
      assert_equal 2, results.size
      assert_equal 1, results.first.source_results.size
    end
  end

  test "team source results" do
    Timecop.freeze(2019, 1) do
      calculation = Calculations::V3::Calculation.create!(
        disciplines: [Discipline[:road]],
        members_only: true,
        name: "Road BAR",
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        show_zero_point_source_results: false,
        weekday_events: false
      )

      event = FactoryBot.create(:event, date: Time.zone.local(2019, 3, 31))
      source_race = FactoryBot.create(:race, event: event)
      FactoryBot.create(:result, race: source_race, place: 1)
      FactoryBot.create(:result, race: source_race, place: 1)
      FactoryBot.create(:result, race: source_race, place: 1)
      FactoryBot.create(:result, race: source_race, place: 2)
      FactoryBot.create(:result, race: source_race, place: 2)

      calculation.calculate!

      bar = calculation.reload.event

      assert_equal "Road BAR", bar.name
      race = bar.races.first

      results = race.results.sort
      assert_equal 5, results.size

      assert_equal [5, 5, 5, 7, 7], results.map(&:points).sort
    end
  end

  test "weekly series overall" do
    Timecop.freeze(2019, 1) do
      bar_calculation = Calculations::V3::Calculation.create!(
        disciplines: [Discipline[:road]],
        members_only: true,
        name: "Road BAR",
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )

      category_3_men = ::Category.find_or_create_by(name: "Category 3 Men")
      bar_calculation.categories << category_3_men

      # Weekly series with no overall
      series = FactoryBot.create(:weekly_series, name: "No overall")
      event = series.children.create!(date: Time.zone.local(2019, 3, 19))
      source_race = event.races.create!(category: category_3_men)
      person = FactoryBot.create(:person)
      source_race.results.create!(place: 7, person: person)

      event = series.children.create!(date: Time.zone.local(2019, 3, 26))
      source_race = event.races.create!(category: category_3_men)
      source_race.results.create!(place: 3, person: person)

      # system calculated
      series = FactoryBot.create(:weekly_series, name: "System calculated overall")
      event = series.children.create!(date: Time.zone.local(2019, 5, 13))
      source_race = event.races.create!(category: category_3_men)
      source_race.results.create!(place: 1, person: person)

      event = series.children.create!(date: Time.zone.local(2019, 5, 20))
      source_race = event.races.create!(category: category_3_men)
      source_race.results.create!(place: 2, person: person)

      series_overall = series.calculations.create!(
        double_points_for_last_event: true,
        points_for_place: [100, 90, 75, 50, 40, 30, 20, 10]
      )
      series_overall.categories << category_3_men
      series_overall.calculate!

      assert_equal_dates Date.new(2019, 5, 13), series_overall.date
      assert_equal_dates Date.new(2019, 5, 20), series_overall.end_date

      # manually calculated
      series = FactoryBot.create(:weekly_series, name: "Manually calculated overall")
      event = series.children.create!(date: Time.zone.local(2019, 4, 12))
      source_race = event.races.create!(category: category_3_men)
      source_race.results.create!(place: 4, person: person)

      event = series.children.create!(date: Time.zone.local(2019, 4, 19))
      source_race = event.races.create!(category: category_3_men)
      source_race.results.create!(place: 3, person: person)

      source_race = series.races.create!(category: category_3_men)
      source_race.results.create!(place: 2, person: person, points: 72)

      bar_calculation.calculate!

      assert_equal_dates Date.new(2019, 4, 12), series.date
      assert_equal_dates Date.new(2019, 4, 19), series.end_date

      bar = bar_calculation.reload.event

      assert_equal "Road BAR", bar.name
      assert_equal 1, bar.races.size
      race = bar.races.detect { |r| r.category == category_3_men }
      assert_not_nil race

      results = race.results
      assert_equal 1, results.size
      assert_equal 8, results.first.sources.size
      assert_equal 6, results.first.sources.count(&:rejected?), results.first.sources.select(&:rejected?).map(&:source_result).map(&:race_full_name)
      assert_equal 2, results.first.sources.reject(&:rejected?).size, results.first.sources.map(&:rejection_reason)
      assert_equal 29, results.first.points
    end
  end

  test "overall BAR" do
    Timecop.freeze(2019, 1) do
      criterium_discipline = Discipline.create!(name: "Criterium")
      circuit_race_discipline = Discipline.create!(name: "Circuit Race")
      road_discipline = Discipline[:road]
      overall_discipline = Discipline.create!(name: "Overall")
      Discipline.create!(name: "Running")
      senior_women = ::Category.find_or_create_by(name: "Senior Women")

      criterium = Calculations::V3::Calculation.create!(
        discipline: criterium_discipline,
        disciplines: [criterium_discipline],
        key: "criterium_bar",
        members_only: true,
        name: "Criterium BAR",
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )
      criterium.categories << senior_women

      road = Calculations::V3::Calculation.create!(
        discipline: road_discipline,
        disciplines: [circuit_race_discipline, road_discipline],
        key: "road_bar",
        name: "Road BAR",
        members_only: true,
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )
      road.categories << senior_women

      overall = Calculations::V3::Calculation.create!(
        discipline: overall_discipline,
        key: "overall_bar",
        members_only: true,
        name: "Overall BAR",
        points_for_place: (1..300).to_a.reverse,
        show_zero_point_source_results: false,
        source_event_keys: %w[criterium_bar road_bar],
        weekday_events: true
      )
      overall.categories << senior_women

      assert_equal ["overall_bar"], road.source_event_parent_keys

      source_event = FactoryBot.create(:event, date: Time.zone.local(2019, 4, 13))
      race = source_event.races.create!(category: senior_women)
      person = FactoryBot.create :person
      race.results.create! place: 12, person: person
      # No points
      race.results.create! place: 16, person: FactoryBot.create(:person)

      # Previous BAR version
      event = Competitions::Bar.create!
      race = event.races.create! category: senior_women
      race.results.create! place: 2, person: person, competition_result: true

      overall.calculate!

      assert_equal 2, overall.source_events.size

      event = criterium.reload.event

      assert_equal 1, event.races.size
      race = event.races.detect { |r| r.category == senior_women }
      assert_not_nil race

      results = race.results.sort
      assert_equal 0, results.size

      event = road.reload.event

      assert_equal 1, event.races.size
      race = event.races.detect { |r| r.category == senior_women }
      assert_not_nil race

      results = race.results.sort
      assert_equal 2, results.size

      assert_equal 1, results.first.source_results.size
      assert_nil results.first.sources.first.rejection_reason
      assert_equal 4, results.first.points
      assert_equal "1", results.first.place

      assert_equal 1, results.second.source_results.size
      assert_nil results.second.sources.first.rejection_reason
      assert_equal 0, results.second.points
      assert_equal "", results.second.place

      event = overall.reload.event
      assert_equal "Overall", event.discipline

      assert_equal 1, event.races.size
      race = event.races.detect { |r| r.category == senior_women }
      assert_not_nil race

      results = race.results.sort
      assert_equal 1, results.size

      assert_equal 1, results.first.source_results.size
      assert_equal 300, results.first.points
      assert_equal "1", results.first.place

      # Idempotent
      overall.calculate!
      assert_equal 2, overall.reload.source_events.size

      # Remove discipline BAR result
      source_event.discipline = "Running"
      source_event.save!

      overall.calculate!

      event = road.reload.event

      assert_equal 1, event.races.size
      race = event.races.detect { |r| r.category == senior_women }
      assert_not_nil race

      results = race.results
      assert_equal 0, results.size

      assert_equal 2, overall.reload.source_events.size
      event = overall.reload.event
      results = event.races.detect { |r| r.category == senior_women }.results
      assert_equal 0, results.size
    end
  end

  test "Overall BAR many disciplines" do
    Timecop.freeze(2019, 1) do
      cyclocross_discipline = Discipline.create!(name: "Cyclocross")
      mtb_discipline = Discipline.create!(name: "Mountain Bike")
      overall_discipline = Discipline.create!(name: "Overall")
      road_discipline = Discipline.find_by!(name: "Road")
      short_track_discipline = Discipline.create!(name: "Short Track")
      time_trial_discipline = Discipline.create!(name: "Time Trial")

      masters_men = Category.create!(name: "Masters Men")

      [
        cyclocross_discipline,
        mtb_discipline,
        road_discipline,
        short_track_discipline,
        time_trial_discipline
      ].each do |discipline|
        calculation = Calculations::V3::Calculation.create!(
          discipline: discipline,
          disciplines: [discipline],
          key: "#{discipline.to_param}_bar",
          members_only: true,
          name: "#{discipline.name} BAR",
          points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          weekday_events: false
        )
        calculation.categories << masters_men
      end

      overall = Calculations::V3::Calculation.create!(
        discipline: overall_discipline,
        key: "overall_bar",
        members_only: true,
        name: "Overall BAR",
        points_for_place: (1..300).to_a.reverse,
        show_zero_point_source_results: false,
        source_event_keys: %w[cyclocross_bar mountain_bike_bar road_bar short_track_bar time_trial_bar],
        weekday_events: true
      )
      overall.categories << masters_men

      source_event = FactoryBot.create(:event, discipline: cyclocross_discipline.name, date: Time.zone.local(2019, 4, 13))
      race = source_event.races.create!(category: masters_men)
      person = FactoryBot.create :person
      race.results.create! place: 1, person: person

      source_event = FactoryBot.create(:event, discipline: mtb_discipline.name, date: Time.zone.local(2019, 4, 13))
      race = source_event.races.create!(category: masters_men)
      race.results.create! place: 1, person: person

      source_event = FactoryBot.create(:event, discipline: road_discipline.name, date: Time.zone.local(2019, 4, 13))
      race = source_event.races.create!(category: masters_men)
      race.results.create! place: 1, person: person

      source_event = FactoryBot.create(:event, discipline: short_track_discipline.name, date: Time.zone.local(2019, 4, 13))
      race = source_event.races.create!(category: masters_men)
      race.results.create! place: 1, person: person

      source_event = FactoryBot.create(:event, discipline: time_trial_discipline.name, date: Time.zone.local(2019, 4, 13))
      race = source_event.races.create!(category: masters_men)
      race.results.create! place: 1, person: person

      overall.calculate!

      assert_equal 5, overall.source_events.size

      event = overall.reload.event
      assert_equal "Overall", event.discipline

      assert_equal 1, event.races.size
      race = event.races.detect { |r| r.category == masters_men }
      assert_not_nil race

      results = race.results.sort
      assert_equal 1, results.size

      assert_equal 5, results.first.source_results.size
      assert_equal 1500, results.first.points
      assert_equal "1", results.first.place
    end
  end

  test "map categories" do
    Timecop.freeze(2019, 1) do
      cyclocross_discipline = Discipline.create!(name: "Cyclocross")
      overall_discipline = Discipline.create!(name: "Overall")
      category_pro_1_2_men = ::Category.find_or_create_by(name: "Category Pro/1/2 Men")
      category_3_men = ::Category.find_or_create_by(name: "Category 3 Men")
      category_2_3_men = ::Category.find_or_create_by(name: "Category 2/3 Men")

      cyclocross = Calculations::V3::Calculation.create!(
        discipline: cyclocross_discipline,
        disciplines: [cyclocross_discipline],
        key: "cyclocross_bar",
        members_only: true,
        name: "Cyclocross BAR",
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )
      cyclocross.categories << category_pro_1_2_men
      cyclocross.categories << category_2_3_men

      overall = Calculations::V3::Calculation.create!(
        discipline: overall_discipline,
        key: "overall_bar",
        members_only: true,
        name: "Overall BAR",
        points_for_place: (1..300).to_a.reverse,
        show_zero_point_source_results: false,
        source_event_keys: %w[cyclocross_bar road_bar],
        weekday_events: true
      )
      overall.categories << category_pro_1_2_men
      calculation_category = overall.calculation_categories.create!(category: category_3_men)
      calculation_category.mappings.create!(category: category_2_3_men, discipline: cyclocross_discipline)

      source_event = FactoryBot.create(:event, date: Time.zone.local(2019, 4, 13), discipline: "Cyclocross")
      race = source_event.races.create!(category: category_2_3_men)
      person = FactoryBot.create :person
      race.results.create! place: 12, person: person

      overall.calculate!

      assert_equal 1, overall.source_events.size

      event = cyclocross.reload.event

      race = event.races.detect { |r| r.category == category_2_3_men }
      assert_not_nil race

      results = race.results.sort
      assert_equal 1, results.size

      event = overall.reload.event
      assert_equal "Overall", event.discipline

      assert_equal 2, event.races.size

      race = event.races.detect { |r| r.category == category_pro_1_2_men }
      assert_not_nil race
      results = race.results.sort
      assert_equal 0, results.size

      race = event.races.detect { |r| r.category == category_3_men }
      assert_not_nil race
      results = race.results.sort
      assert_equal 1, results.size
    end
  end

  test "Age-Graded BAR" do
    Timecop.freeze(2019, 1) do
      age_graded_discipline = Discipline.create!(name: "Age Graded")
      circuit_race_discipline = Discipline.create!(name: "Circuit Race")
      criterium_discipline = Discipline.create!(name: "Criterium")
      overall_discipline = Discipline.create!(name: "Overall")
      road_discipline = Discipline[:road]

      masters_men = ::Category.find_or_create_by(name: "Masters Men")
      masters_men_30_34 = ::Category.find_or_create_by(name: "Masters Men 30-34")
      masters_men_35_39 = ::Category.find_or_create_by(name: "Masters Men 35-39")
      masters_women = ::Category.find_or_create_by(name: "Masters Women")
      masters_women_60_plus = ::Category.find_or_create_by(name: "Masters Women 60+")
      senior_women = ::Category.find_or_create_by(name: "Senior Women")

      criterium = Calculations::V3::Calculation.create!(
        discipline: criterium_discipline,
        disciplines: [criterium_discipline],
        key: "criterium_bar",
        members_only: true,
        name: "Criterium BAR",
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )
      criterium.categories << senior_women
      criterium.categories << masters_men
      criterium.categories << masters_women

      road = Calculations::V3::Calculation.create!(
        discipline: road_discipline,
        disciplines: [circuit_race_discipline, road_discipline],
        key: "road_bar",
        name: "Road BAR",
        members_only: true,
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )
      road.categories << senior_women
      road.categories << masters_men
      road.categories << masters_women

      overall = Calculations::V3::Calculation.create!(
        discipline: overall_discipline,
        key: "overall_bar",
        members_only: true,
        name: "Overall BAR",
        points_for_place: (1..300).to_a.reverse,
        show_zero_point_source_results: false,
        source_event_keys: %w[criterium_bar road_bar],
        weekday_events: true
      )
      overall.categories << senior_women
      overall.categories << masters_men
      overall.categories << masters_women

      age_graded = Calculations::V3::Calculation.create!(
        discipline: age_graded_discipline,
        group_by: :age,
        members_only: true,
        name: "Age-Graded BAR",
        show_zero_point_source_results: false,
        source_event_keys: %w[overall_bar],
        weekday_events: true
      )
      age_graded.categories << masters_men_30_34
      age_graded.categories << masters_men_35_39
      age_graded.categories << masters_women_60_plus

      source_event = FactoryBot.create(:event, date: Time.zone.local(2019, 4, 13))
      race = source_event.races.create!(category: senior_women)
      person = FactoryBot.create :person
      race.results.create! place: 12, person: person

      race = source_event.races.create!(category: masters_men)
      person = FactoryBot.create :person, date_of_birth: 37.years.ago
      race.results.create! place: 4, person: person

      race = source_event.races.create!(category: masters_men)
      person = FactoryBot.create :person, date_of_birth: 31.years.ago
      race.results.create! place: 2, person: person

      race = source_event.races.create!(category: masters_women)
      person = FactoryBot.create :person, date_of_birth: 72.years.ago
      race.results.create! place: 14, person: person

      age_graded.calculate!

      assert_equal 1, age_graded.source_events.size
      event = age_graded.reload.event
      assert_equal 0, event.races.count(&:rejected), event.races.select(&:rejected).map(&:name)
      assert_equal 3, event.races.size, event.races.map(&:name)

      race = event.races.detect { |r| r.category == masters_men_30_34 }
      results = race.results.sort
      assert_equal 1, results.size
      assert_equal 300, results.first.points
      assert_equal "1", results.first.place

      race = event.races.detect { |r| r.category == masters_men_35_39 }
      results = race.results.sort
      assert_equal 1, results.size
      assert_equal 299, results.first.points
      assert_equal "1", results.first.place

      race = event.races.detect { |r| r.category == masters_women_60_plus }
      results = race.results.sort
      assert_equal 1, results.size
      assert_equal 300, results.first.points
      assert_equal "1", results.first.place
    end
  end
end
