# frozen_string_literal: true

require "application_system_test_case"

module Competitions
  # :stopdoc:
  class PublicPagesApplicationSystemTestCase < ApplicationSystemTestCase
    test "popular pages" do
      create_results

      ::Calculations::V3::Calculation.create!(
        key: :ironman,
        members_only: true,
        name: "Ironman",
        points_for_place: 1
      ).calculate!

      calculation = ::Calculations::V3::Calculation.create!(
        key: :oregon_cup,
        name: "Oregon Cup",
        members_only: true,
        points_for_place: [100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10],
        specific_events: true
      )

      calculation.calculation_categories.create!(category: Category.find_by(name: "Senior Men"))
      calculation.calculations_events.create!(event: @new_event, multiplier: 1)
      calculation.calculate!

      visit "/ironman"
      assert_page_has_content "Ironman"

      visit "/oregon_cup"
      assert_page_has_content "Oregon Cup"
    end

    test "bar" do
      overall_discipline = FactoryBot.create(:discipline, name: "Overall")
      FactoryBot.create(:discipline, name: "Mountain Bike")
      age_graded = FactoryBot.create(:discipline, name: "Age Graded")
      masters_men = FactoryBot.create(:category, name: "Masters Men")
      masters_30_34 = FactoryBot.create(:category, name: "Masters Men 30-34", ages: 30..34, parent: masters_men)
      FactoryBot.create(:category, name: "Masters Men 35-39", ages: 35..39, parent: masters_men)

      road = FactoryBot.create(:discipline, name: "Road")

      calculation = ::Calculations::V3::Calculation.create!(
        disciplines: [road],
        field_size_bonus: true,
        members_only: true,
        key: :road_bar,
        name: "Road BAR",
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false,
        year: 2009
      )
      calculation.categories << masters_men

      calculation = ::Calculations::V3::Calculation.create!(
        discipline: overall_discipline,
        event_notes: "Oregon Best All-Around Rider",
        key: "overall_bar",
        members_only: true,
        name: "Overall BAR",
        points_for_place: (1..300).to_a.reverse,
        source_event_keys: %w[road_bar],
        weekday_events: true,
        year: 2009
      )
      calculation.categories << masters_men

      calculation = ::Calculations::V3::Calculation.create!(
        discipline: age_graded,
        group_by: :age,
        members_only: true,
        name: "Age-Graded BAR",
        source_event_keys: %w[overall_bar],
        weekday_events: true,
        year: 2009
      )
      calculation.categories << masters_30_34

      # Masters 30-34 result. (32)
      weaver = FactoryBot.create(:person, date_of_birth: Date.new(1977))
      banana_belt_1 = FactoryBot.create(:event, date: Date.new(2009, 3))

      Timecop.freeze(2009, 4) do
        banana_belt_masters_30_34 = banana_belt_1.races.create!(category: masters_30_34)
        banana_belt_masters_30_34.results.create!(person: weaver, place: "10")

        calculation.calculate!
      end

      calculation.calculate!

      visit "/bar"
      assert_page_has_content "BAR"
      assert_page_has_content "Oregon Best All-Around Rider"

      visit "/bar/2009"
      page.has_css?("title", text: /BAR/)

      visit "/bar/2009/age_graded"
      assert_page_has_content "Masters Men"

      visit "/bar/#{Time.zone.today.year}"
      assert_page_has_content "Overall"

      visit "/bar/#{Time.zone.today.year}/age_graded"
      page.has_css?("title", text: /Age Graded/)
    end

    private

    def create_results
      FactoryBot.create(:discipline, name: "Road")
      FactoryBot.create(:discipline, name: "Track")
      FactoryBot.create(:discipline, name: "Time Trial")
      FactoryBot.create(:discipline, name: "Cyclocross")

      promoter = FactoryBot.create(:person, name: "Brad Ross", home_phone: "(503) 555-1212")
      @new_event = FactoryBot.create(:event, promoter: promoter, date: Date.new(Time.zone.now.year, 5))
      @alice = FactoryBot.create(:person, name: "Alice Pennington")
      Timecop.freeze(Time.zone.local(Time.zone.now.year, 5, 2)) do
        FactoryBot.create(:result, event: @new_event)
      end

      FactoryBot.create(:event, name: "Kings Valley Road Race", date: Time.zone.local(2004).end_of_year.to_date)
                .races.create!(category: FactoryBot.create(:category, name: "Senior Women 1/2/3"))
                .results.create!(place: "2", person: @alice)

      event = FactoryBot.create(:event, name: "Jack Frost", date: Time.zone.local(2002, 1, 17), discipline: "Time Trial")
      event.races.create!(category: FactoryBot.create(:category, name: "Senior Women")).results.create!(place: "1", person: @alice)
      weaver = FactoryBot.create(:person, name: "Ryan Weaver")
      event.races.create!(category: FactoryBot.create(:category, name: "Senior Men")).results.create!(place: "2", person: weaver)

      FactoryBot.create(:team, name: "Gentle Lovers")
      FactoryBot.create(:team, name: "Vanilla")
    end
  end
end
