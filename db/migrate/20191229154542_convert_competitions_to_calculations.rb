# frozen_string_literal: true

class ConvertCompetitionsToCalculations < ActiveRecord::Migration[5.2]
  def up
    Calculations::V3::Calculation.reset_column_information
    transaction do
      Competitions::Bar.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        discipline = Discipline.find_by(name: competition.discipline)
        calculation = Calculations::V3::Calculation.create!(
          association_sanctioned_only: true,
          event_notes: "Rules before 2020 may not be accurate",
          discipline: discipline,
          disciplines: [discipline],
          group: :bar,
          key: "#{discipline.to_param}_bar",
          members_only: true,
          name: competition.full_name,
          points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          weekday_events: false,
          year: competition.year
        )

        create_category(calculation, "Category 1/2 Men")
        create_category(calculation, "Athena")
        create_category(calculation, "Category 3 Men")
        create_category(calculation, "Category 3 Women")
        create_category(calculation, "Category 4 Men")
        create_category(calculation, "Category 4 Women")
        create_category(calculation, "Category 5 Men")
        create_category(calculation, "Category 5 Women")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Junior Men")
        create_category(calculation, "Junior Women")
        create_category(calculation, "Masters Men")
        create_category(calculation, "Masters Women")
        create_category(calculation, "Category Pro/1/2 Men")
        create_category(calculation, "Category Pro/1/2 Women")
        create_category(calculation, "Singlespeed/Fixed")
        create_category(calculation, "Tandem")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::AgeGradedBar.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        discipline = Discipline.find_by(name: competition.discipline)
        calculation = Calculations::V3::Calculation.create!(
          association_sanctioned_only: true,
          event_notes: "Rules before 2020 may not be accurate",
          discipline: discipline,
          group: :bar,
          key: :age_graded_bar,
          members_only: true,
          name: competition.full_name,
          source_event_keys: [:overall_bar],
          weekday_events: false,
          year: competition.year
        )

        create_category(calculation, "Junior Men 10-12")
        create_category(calculation, "Junior Men 13-14")
        create_category(calculation, "Junior Men 15-16")
        create_category(calculation, "Junior Men 17-18")
        create_category(calculation, "Junior Women 10-12")
        create_category(calculation, "Junior Women 13-14")
        create_category(calculation, "Junior Women 15-16")
        create_category(calculation, "Junior Women 17-18")
        create_category(calculation, "Masters Men 30-34")
        create_category(calculation, "Masters Men 35-39")
        create_category(calculation, "Masters Men 40-44")
        create_category(calculation, "Masters Men 45-49")
        create_category(calculation, "Masters Men 50-54")
        create_category(calculation, "Masters Men 55-59")
        create_category(calculation, "Masters Men 60-64")
        create_category(calculation, "Masters Men 65-69")
        create_category(calculation, "Masters Men 70+")
        create_category(calculation, "Masters Women 30-34")
        create_category(calculation, "Masters Women 35-39")
        create_category(calculation, "Masters Women 40-44")
        create_category(calculation, "Masters Women 45-49")
        create_category(calculation, "Masters Women 50-54")
        create_category(calculation, "Masters Women 55-59")
        create_category(calculation, "Masters Women 60+")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::BlindDateAtTheDairyOverall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :blind_date_at_the_dairy,
          key: :blind_date_at_the_dairy,
          name: "Blind Date at the Dairy",
          maximum_events: -1,
          points_for_place: [15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          year: competition.year
        )

        create_category(calculation, "Athena")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Elite Junior Men")
        create_category(calculation, "Elite Junior Women", maximum_events: -2)
        create_category(calculation, "Junior Men 9-12")
        create_category(calculation, "Junior Men 13-14")
        create_category(calculation, "Junior Men 15-16")
        create_category(calculation, "Junior Men 17-18")
        create_category(calculation, "Junior Men 3/4/5")
        create_category(calculation, "Junior Men 9-12 3/4/5", reject: true)
        create_category(calculation, "Junior Women 9-12")
        create_category(calculation, "Junior Women 13-14")
        create_category(calculation, "Junior Women 15-16")
        create_category(calculation, "Junior Women 17-18")
        create_category(calculation, "Junior Women 3/4/5")
        create_category(calculation, "Junior Women 9-12 3/4/5", reject: true)
        create_category(calculation, "Masters 35+ 1/2")
        create_category(calculation, "Masters 35+ 3")
        create_category(calculation, "Masters 35+ 4")
        create_category(calculation, "Masters 50+")
        create_category(calculation, "Masters 60+")
        create_category(calculation, "Masters 70+")
        create_category(calculation, "Masters Women 35+ 1/2", maximum_events: -2)
        create_category(calculation, "Masters Women 35+ 3", maximum_events: -2)
        create_category(calculation, "Masters Women 50+", maximum_events: -2)
        create_category(calculation, "Masters Women 60+", maximum_events: -2)
        create_category(calculation, "Men 1/2")
        create_category(calculation, "Men 2/3")
        create_category(calculation, "Men 4")
        create_category(calculation, "Men 5")
        create_category(calculation, "Singlespeed Women")
        create_category(calculation, "Singlespeed")
        create_category(calculation, "Women 1/2")
        create_category(calculation, "Women 2/3", maximum_events: -2)
        create_category(calculation, "Women 4", maximum_events: -2)
        create_category(calculation, "Women 5", maximum_events: -2)

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::BlindDateAtTheDairyMonthlyStandings.all.each do |competition|
        month_name = Date::MONTHNAMES[competition.date.month]
        puts "#{competition.year} #{month_name} #{competition.type}"

        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :blind_date_at_the_dairy,
          key: "blind_date_at_the_dairy_#{month_name.downcase}_standings",
          name: "Blind Date at the Dairy #{month_name} Standings",
          points_for_place: [15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          year: competition.year
        )

        create_category(calculation, "Athena")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Elite Junior Men")
        create_category(calculation, "Elite Junior Women", maximum_events: -2)
        create_category(calculation, "Junior Men 9-12")
        create_category(calculation, "Junior Men 13-14")
        create_category(calculation, "Junior Men 15-16")
        create_category(calculation, "Junior Men 17-18")
        create_category(calculation, "Junior Men 3/4/5")
        create_category(calculation, "Junior Men 9-12 3/4/5", reject: true)
        create_category(calculation, "Junior Women 9-12")
        create_category(calculation, "Junior Women 13-14")
        create_category(calculation, "Junior Women 15-16")
        create_category(calculation, "Junior Women 17-18")
        create_category(calculation, "Junior Women 3/4/5")
        create_category(calculation, "Junior Women 9-12 3/4/5", reject: true)
        create_category(calculation, "Masters 35+ 1/2")
        create_category(calculation, "Masters 35+ 3")
        create_category(calculation, "Masters 35+ 4")
        create_category(calculation, "Masters 50+")
        create_category(calculation, "Masters 60+")
        create_category(calculation, "Masters 70+")
        create_category(calculation, "Masters Women 35+ 1/2", maximum_events: -2)
        create_category(calculation, "Masters Women 35+ 3", maximum_events: -2)
        create_category(calculation, "Masters Women 50+", maximum_events: -2)
        create_category(calculation, "Masters Women 60+", maximum_events: -2)
        create_category(calculation, "Men 1/2")
        create_category(calculation, "Men 2/3")
        create_category(calculation, "Men 4")
        create_category(calculation, "Men 5")
        create_category(calculation, "Singlespeed Women")
        create_category(calculation, "Singlespeed")
        create_category(calculation, "Women 1/2")
        create_category(calculation, "Women 2/3", maximum_events: -2)
        create_category(calculation, "Women 4", maximum_events: -2)
        create_category(calculation, "Women 5", maximum_events: -2)

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::BlindDateAtTheDairyTeamCompetition.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          results_per_event: 10,
          team: true,
          event_notes: "Rules before 2020 may not be accurate",
          group: :blind_date_at_the_dairy,
          key: :blind_date_at_the_dairy_team_competition,
          name: "Blind Date at the Dairy Team Competition",
          maximum_events: -1,
          points_for_place: [15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          year: competition.year
        )
        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::Cat4WomensRaceSeries.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          key: :category_4_womens_race_series,
          name: "Cat 4 Womens Race Series",
          year: competition.year
        )

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::CrossCrusadeCallups.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          key: :cross_crusade_callups,
          name: "Cross Crusade Callups",
          year: competition.year
        )

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::Competition.where(type: ["Competitions::Competition", "Competitions::OregonTTCup"]).each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          key: :oregon_tt_cup,
          name: "OBRA Time Trial Cup",
          members_only: true,
          place_by: "time",
          points_for_place: [20, 17, 15, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          specific_events: true,
          year: competition.year
        )

        create_category(calculation, "Category 3 Men")
        create_category(calculation, "Category 3 Women")
        create_category(calculation, "Category 4/5 Men")
        create_category(calculation, "Category 4/5 Women")
        create_category(calculation, "Eddy Senior Men")
        create_category(calculation, "Eddy Senior Women")
        create_category(calculation, "Junior Men 10-12")
        create_category(calculation, "Junior Men 13-14")
        create_category(calculation, "Junior Men 15-16")
        create_category(calculation, "Junior Men 17-18")
        create_category(calculation, "Junior Women 10-14")
        create_category(calculation, "Junior Women 15-18")
        create_category(calculation, "Masters Men 30-39")
        create_category(calculation, "Masters Men 40-49")
        create_category(calculation, "Masters Men 50-59")
        create_category(calculation, "Masters Men 60-69")
        create_category(calculation, "Masters Men 70+")
        create_category(calculation, "Masters Women 30-39")
        create_category(calculation, "Masters Women 40-49")
        create_category(calculation, "Masters Women 50-59")
        create_category(calculation, "Masters Women 60-69")
        create_category(calculation, "Masters Women 70+")
        create_category(calculation, "Senior Men Pro/1/2")
        create_category(calculation, "Senior Women Pro/1/2")
        create_category(calculation, "Tandem")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::CrossCrusadeOverall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :cross_crusade,
          key: :cross_crusade_overall,
          name: "River City Bicycles Cyclocross Crusade",
          maximum_events: -1,
          minimum_events: 3,
          points_for_place: [26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          year: competition.year
        )

        create_category(calculation, "Athena")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Elite Junior Men")
        create_category(calculation, "Elite Junior Women", maximum_events: -2)
        create_category(calculation, "Junior Men 9-12")
        create_category(calculation, "Junior Men 13-14")
        create_category(calculation, "Junior Men 15-16")
        create_category(calculation, "Junior Men 17-18")
        create_category(calculation, "Junior Men 3/4/5")
        create_category(calculation, "Junior Men 9-12 3/4/5", reject: true)
        create_category(calculation, "Junior Women 9-12")
        create_category(calculation, "Junior Women 13-14")
        create_category(calculation, "Junior Women 15-16")
        create_category(calculation, "Junior Women 17-18")
        create_category(calculation, "Junior Women 3/4/5")
        create_category(calculation, "Junior Women 9-12 3/4/5", reject: true)
        create_category(calculation, "Masters 35+ 1/2")
        create_category(calculation, "Masters 35+ 3")
        create_category(calculation, "Masters 35+ 4")
        create_category(calculation, "Masters 50+")
        create_category(calculation, "Masters 60+")
        create_category(calculation, "Masters 70+")
        create_category(calculation, "Masters Women 35+ 1/2", maximum_events: -2)
        create_category(calculation, "Masters Women 35+ 3", maximum_events: -2)
        create_category(calculation, "Masters Women 50+", maximum_events: -2)
        create_category(calculation, "Masters Women 60+", maximum_events: -2)
        create_category(calculation, "Men 1/2")
        create_category(calculation, "Men 2/3")
        create_category(calculation, "Men 4")
        create_category(calculation, "Men 5")
        create_category(calculation, "Singlespeed Women")
        create_category(calculation, "Singlespeed")
        create_category(calculation, "Women 1/2")
        create_category(calculation, "Women 2/3", maximum_events: -2)
        create_category(calculation, "Women 4", maximum_events: -2)
        create_category(calculation, "Women 5", maximum_events: -2)

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::CrossCrusadeTeamCompetition.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :cross_crusade,
          key: :cross_crusade_team_competition,
          name: "River City Bicycles Cyclocross Crusade Team Competition",
          missing_result_penalty: 100,
          place_by: "fewest_points",
          points_for_place: (1..100).to_a,
          results_per_event: 10,
          team: true,
          year: competition.year
        )

        create_category(calculation, "Junior Men 3/4/5", reject: true)
        create_category(calculation, "Junior Women 3/4/5", reject: true)

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::DirtyCirclesOverall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          key: :dirty_circles_overall,
          name: competition.full_name,
          year: competition.year
        )

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::GrandPrixBradRoss::Overall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :grand_prix,
          key: :grand_prix_overall,
          name: competition.full_name,
          maximum_events: -1,
          minimum_events: 4,
          points_for_place: [100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          year: competition.year
        )

        create_category(calculation, "Athena")
        create_category(calculation, "Category 1/2 35+ Men")
        create_category(calculation, "Category 1/2 35+ Women")
        create_category(calculation, "Category 1/2 Men")
        create_category(calculation, "Category 1/2 Women")
        create_category(calculation, "Category 2/3 Men")
        create_category(calculation, "Category 2/3 Women")
        create_category(calculation, "Category 3 35+ Men")
        create_category(calculation, "Category 3 35+ Women")
        create_category(calculation, "Category 3 Women")
        create_category(calculation, "Category 4 35+ Men")
        create_category(calculation, "Category 4 Men")
        create_category(calculation, "Category 4 Women")
        create_category(calculation, "Category 5 Men")
        create_category(calculation, "Category 5 Women")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Elite Junior Men")
        create_category(calculation, "Elite Junior Women")
        create_category(calculation, "Junior Men 13-14 3/4/5", reject: true)
        create_category(calculation, "Junior Men 15-16 3/4/5", reject: true)
        create_category(calculation, "Junior Men 17-18 3/4/5", reject: true)
        create_category(calculation, "Junior Men 3/4/5")
        create_category(calculation, "Junior Men 9-12 3/4/5", reject: true)
        create_category(calculation, "Junior Women 13-14 3/4/5", reject: true)
        create_category(calculation, "Junior Women 15-16 3/4/5", reject: true)
        create_category(calculation, "Junior Women 17-18 3/4/5", reject: true)
        create_category(calculation, "Junior Women 3/4/5")
        create_category(calculation, "Junior Women 9-12 3/4/5", reject: true)
        create_category(calculation, "Masters 50+ Men")
        create_category(calculation, "Masters 50+ Women")
        create_category(calculation, "Masters 60+ Men")
        create_category(calculation, "Masters 60+ Women")
        create_category(calculation, "Singlespeed Men")
        create_category(calculation, "Singlespeed Women")
        create_category(calculation, "Athena")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::GrandPrixBradRoss::TeamStandings.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :grand_prix,
          key: :grand_prix_team_competition,
          name: competition.full_name,
          team: true,
          year: competition.year
        )

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::Ironman.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "The Ironman Competition is a 'just for fun' record of the number of events riders do. There is no prize just identification of riders who need to get a life.",
          key: :ironman,
          members_only: true,
          name: "Ironman",
          points_for_place: 1,
          year: competition.year
        )

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::OregonCup.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: oregon_cup_notes,
          key: :oregon_cup,
          members_only: true,
          name: "Oregon Cup",
          points_for_place: [100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10],
          specific_events: true,
          year: competition.year
        )

        create_category(calculation, "Category 1/2 Men")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::OregonJuniorCyclocrossSeries::Overall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :ojcs,
          key: :ojcs,
          members_only: true,
          name: competition.full_name,
          maximum_events: -2,
          points_for_place: [30, 28, 26, 24, 22, 20, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          specific_events: true,
          year: competition.year
        )

        create_category(calculation, "Elite Junior Men")
        create_category(calculation, "Elite Junior Women")
        create_category(calculation, "Junior Men 10-12", reject: true)
        create_category(calculation, "Junior Men 13-14 3/4/5")
        create_category(calculation, "Junior Men 13-14", reject: true)
        create_category(calculation, "Junior Men 15-16 3/4/5")
        create_category(calculation, "Junior Men 15-16", reject: true)
        create_category(calculation, "Junior Men 17-18 3/4/5")
        create_category(calculation, "Junior Men 17-18", reject: true)
        create_category(calculation, "Junior Men 9-12 3/4/5")
        create_category(calculation, "Junior Men 9", reject: true)
        create_category(calculation, "Junior Women 10-12", reject: true)
        create_category(calculation, "Junior Women 13-14 3/4/5")
        create_category(calculation, "Junior Women 13-14", reject: true)
        create_category(calculation, "Junior Women 15-16 3/4/5")
        create_category(calculation, "Junior Women 15-16", reject: true)
        create_category(calculation, "Junior Women 17-18 3/4/5")
        create_category(calculation, "Junior Women 17-18", reject: true)
        create_category(calculation, "Junior Women 9-12 3/4/5")
        create_category(calculation, "Junior Women 9", reject: true)

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::OregonJuniorCyclocrossSeries::Team.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :ojcs,
          key: :ojcs_team,
          members_only: true,
          name: competition.full_name,
          maximum_events: -2,
          points_for_place: (1..30).to_a.reverse,
          specific_events: true,
          team: true,
          year: competition.year
        )

        create_category(calculation, "Junior Men 1/2/3")
        create_category(calculation, "Junior Men 13-14 3/4/5")
        create_category(calculation, "Junior Men 15-16 3/4/5")
        create_category(calculation, "Junior Men 17-18 3/4/5")
        create_category(calculation, "Junior Men 9-12 3/4/5")
        create_category(calculation, "Junior Women 1/2/3")
        create_category(calculation, "Junior Women 13-14 3/4/5")
        create_category(calculation, "Junior Women 15-16 3/4/5")
        create_category(calculation, "Junior Women 17-18 3/4/5")
        create_category(calculation, "Junior Women 9-12 3/4/5")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::OregonJuniorMountainBikeSeries::Overall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          discipline: Discipline[:mountain_bike],
          key: :ojmtbs_team,
          name: competition.full_name,
          maximum_events: -2,
          points_for_place: [30, 28, 26, 24, 22, 20, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          specific_events: true,
          year: competition.year
        )

        create_category(calculation, "Category 3 Junior Men 10-13")
        create_category(calculation, "Category 3 Junior Men 14-18")
        create_category(calculation, "Category 3 Junior Women 10-13")
        create_category(calculation, "Category 3 Junior Women 14-18")
        create_category(calculation, "Junior Expert Men")
        create_category(calculation, "Junior Expert Women")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::OregonTTCup.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          key: :oregon_tt_cup,
          members_only: true,
          name: competition.full_name,
          place_by: "time",
          points_for_place: [20, 17, 15, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          specific_events: true,
          year: competition.year
        )

        create_category(calculation, "Category 1 Men U45")
        create_category(calculation, "Category 1 Men 45+")
        create_category(calculation, "Category 2 Men 40-49")
        create_category(calculation, "Category 2 Men 50-59")
        create_category(calculation, "Category 2 Men 60+")
        create_category(calculation, "Category 2 Men U40")
        create_category(calculation, "Category 2 Women 45+")
        create_category(calculation, "Category 2 Women U45")
        create_category(calculation, "Category 3 Men 10-13")
        create_category(calculation, "Category 3 Men 14-18")
        create_category(calculation, "Category 3 Men 19-39")
        create_category(calculation, "Category 3 Men 40-49")
        create_category(calculation, "Category 3 Men 50+")
        create_category(calculation, "Category 3 Women 10-13")
        create_category(calculation, "Category 3 Women 14-18")
        create_category(calculation, "Category 3 Women 19+")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Elite Men")
        create_category(calculation, "Elite/Category 1 Women")
        create_category(calculation, "Singlespeed")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::OregonWomensPrestigeSeries.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :oregon_womens_prestige_series,
          key: :oregon_womens_prestige_series,
          members_only: true,
          name: competition.full_name,
          points_for_place: [25, 21, 18, 16, 14, 12, 10, 8, 7, 6, 5, 4, 3, 2, 1],
          specific_events: true,
          year: competition.year
        )

        create_category(calculation, "Women 1/2")
        create_category(calculation, "Women 3")
        create_category(calculation, "Women 4")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::OregonWomensPrestigeTeamSeries.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :oregon_womens_prestige_series,
          key: :oregon_womens_prestige_team_series,
          members_only: true,
          name: competition.full_name,
          points_for_place: [25, 21, 18, 16, 14, 12, 10, 8, 7, 6, 5, 4, 3, 2, 1],
          specific_events: true,
          team: true,
          year: competition.year
        )

        create_category(calculation, "Women 1/2")
        create_category(calculation, "Women 3")
        create_category(calculation, "Women 4")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::OverallBar.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          association_sanctioned_only: true,
          event_notes: bar_event_notes,
          discipline: Discipline[:overall],
          group: :bar,
          key: :overall_bar,
          maximum_events: -3,
          members_only: true,
          name: competition.full_name,
          points_for_place: (1..300).to_a.reverse,
          source_event_keys: %w[criterium_bar cyclocross_bar gravel_bar mountain_bike_bar road_bar short_track_bar time_trial_bar track_bar],
          specific_events: true,
          weekday_events: true,
          year: competition.year
        )

        create_category(calculation, "Category 1/2 Men")
        create_category(calculation, "Athena")
        create_category(calculation, "Category 3 Men")
        create_category(calculation, "Category 3 Women")
        create_category(calculation, "Category 4 Men")
        create_category(calculation, "Category 4 Women")
        create_category(calculation, "Category 5 Men")
        create_category(calculation, "Category 5 Women")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Junior Men")
        create_category(calculation, "Junior Women")
        create_category(calculation, "Masters Men")
        create_category(calculation, "Masters Women")
        create_category(calculation, "Category Pro/1/2 Men")
        create_category(calculation, "Category Pro/1/2 Women")
        create_category(calculation, "Singlespeed/Fixed")
        create_category(calculation, "Tandem")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::PortlandShortTrackSeries::MonthlyStandings.all.each do |competition|
        month_name = Date::MONTHNAMES[competition.date.month]
        puts "#{competition.year} #{month_name} #{competition.type}"

        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :pdx_stxc,
          key: "pdx_stxc_#{month_name.downcase}_standings",
          name: "Portland Short Track Series #{month_name} Standings",
          maximum_events: -1,
          points_for_place: [
            100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14,
            13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
          ],
          year: competition.year
        )

        create_category(calculation, "Category 1 Men U45")
        create_category(calculation, "Category 1 Men 45+")
        create_category(calculation, "Category 2 Men 40-49")
        create_category(calculation, "Category 2 Men 50-59")
        create_category(calculation, "Category 2 Men 60+")
        create_category(calculation, "Category 2 Men U40")
        create_category(calculation, "Category 2 Women 45+")
        create_category(calculation, "Category 2 Women U45")
        create_category(calculation, "Category 3 Men 10-13")
        create_category(calculation, "Category 3 Men 14-18")
        create_category(calculation, "Category 3 Men 19-39")
        create_category(calculation, "Category 3 Men 40-49")
        create_category(calculation, "Category 3 Men 50+")
        create_category(calculation, "Category 3 Women 10-13")
        create_category(calculation, "Category 3 Women 14-18")
        create_category(calculation, "Category 3 Women 19+")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Elite Men")
        create_category(calculation, "Elite/Category 1 Women")
        create_category(calculation, "Singlespeed")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::PortlandShortTrackSeries::Overall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"

        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :pdx_stxc,
          key: "pdx_stxc_",
          name: competition.full_name,
          maximum_events: -1,
          points_for_place: [
            100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14,
            13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
          ],
          year: competition.year
        )

        create_category(calculation, "Category 1 Men U45")
        create_category(calculation, "Category 1 Men 45+")
        create_category(calculation, "Category 2 Men 40-49")
        create_category(calculation, "Category 2 Men 50-59")
        create_category(calculation, "Category 2 Men 60+")
        create_category(calculation, "Category 2 Men U40")
        create_category(calculation, "Category 2 Women 45+")
        create_category(calculation, "Category 2 Women U45")
        create_category(calculation, "Category 3 Men 10-13")
        create_category(calculation, "Category 3 Men 14-18")
        create_category(calculation, "Category 3 Men 19-39")
        create_category(calculation, "Category 3 Men 40-49")
        create_category(calculation, "Category 3 Men 50+")
        create_category(calculation, "Category 3 Women 10-13")
        create_category(calculation, "Category 3 Women 14-18")
        create_category(calculation, "Category 3 Women 19+")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Elite Men")
        create_category(calculation, "Elite/Category 1 Women")
        create_category(calculation, "Singlespeed")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::PortlandShortTrackSeries::TeamStandings.all.each do |competition|
        month_name = Date::MONTHNAMES[competition.date.month]
        puts "#{competition.year} #{month_name} #{competition.type}"

        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          group: :pdx_stxc,
          key: "pdx_stxc_#{month_name}",
          name: competition.name,
          maximum_events: -1,
          results_per_event: 10,
          points_for_place: [15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          team: true,
          year: competition.year
        )

        create_category(calculation, "Category 1 Men U45")
        create_category(calculation, "Category 1 Men 45+")
        create_category(calculation, "Category 2 Men 40-49")
        create_category(calculation, "Category 2 Men 50-59")
        create_category(calculation, "Category 2 Men 60+")
        create_category(calculation, "Category 2 Men U40")
        create_category(calculation, "Category 2 Women 45+")
        create_category(calculation, "Category 2 Women U45")
        create_category(calculation, "Category 3 Men 10-13")
        create_category(calculation, "Category 3 Men 14-18")
        create_category(calculation, "Category 3 Men 19-39")
        create_category(calculation, "Category 3 Men 40-49")
        create_category(calculation, "Category 3 Men 50+")
        create_category(calculation, "Category 3 Women 10-13")
        create_category(calculation, "Category 3 Women 14-18")
        create_category(calculation, "Category 3 Women 19+")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Elite Men")
        create_category(calculation, "Elite/Category 1 Women")
        create_category(calculation, "Singlespeed")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::PortlandTrophyCup.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          key: :portland_trophy_cup,
          name: competition.name,
          double_points_for_last_event: true,
          points_for_place: [25, 20, 16, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 1],
          year: competition.year
        )

        create_category(calculation, "Junior Open")
        create_category(calculation, "Junior Women")
        create_category(calculation, "Open 1/2")
        create_category(calculation, "Open 3/4 35+")
        create_category(calculation, "Open 3/4")
        create_category(calculation, "Open 50+")
        create_category(calculation, "Open 60+")
        create_category(calculation, "Open Beginner")
        create_category(calculation, "Open Masters 1/2 35+")
        create_category(calculation, "Open Singlespeed")
        create_category(calculation, "Women 1/2")
        create_category(calculation, "Women 3/4")
        create_category(calculation, "Women Beginner")
        create_category(calculation, "Women Singlespeed")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::TaborOverall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          key: :tabor,
          name: competition.name,
          double_points_for_last_event: true,
          points_for_place: [100, 70, 50, 40, 36, 32, 28, 24, 20, 16, 15, 14, 13, 12, 11],
          year: competition.year
        )

        create_category(calculation, "Senior Men")
        create_category(calculation, "Category 3 Men")
        create_category(calculation, "Category 4 Men")
        create_category(calculation, "Category 4/5 Women")
        create_category(calculation, "Category 5 Men")
        create_category(calculation, "Masters Men 50+")
        create_category(calculation, "Masters Men 40+")
        create_category(calculation, "Senior Women")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::TeamBar.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          association_sanctioned_only: true,
          event_notes: "Rules before 2020 may not be accurate",
          discipline: Discipline[:team],
          group: :bar,
          key: :team_bar,
          members_only: true,
          name: competition.full_name,
          points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          team: true,
          weekday_events: false,
          year: competition.year
        )

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::ThrillaOverall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          key: :thrilla_overall,
          name: competition.name,
          double_points_for_last_event: true,
          points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          year: competition.year
        )

        create_category(calculation, "Athena")
        create_category(calculation, "Category 1/2 Masters Men 35+")
        create_category(calculation, "Category 1/2 Masters Women 35+")
        create_category(calculation, "Category 1/2 Men")
        create_category(calculation, "Category 1/2 Women")
        create_category(calculation, "Category 3 Masters Men 35+")
        create_category(calculation, "Category 3 Masters Women 35+")
        create_category(calculation, "Category 3 Men")
        create_category(calculation, "Category 3 Women")
        create_category(calculation, "Category 3/4/5 Junior Men")
        create_category(calculation, "Category 3/4/5 Junior Women")
        create_category(calculation, "Category 4 Masters Men 35+")
        create_category(calculation, "Category 4 Men")
        create_category(calculation, "Category 4 Women")
        create_category(calculation, "Category 5 Men")
        create_category(calculation, "Category 5 Women")
        create_category(calculation, "Clydesdale")
        create_category(calculation, "Masters Men 50+")
        create_category(calculation, "Masters Men 60+")
        create_category(calculation, "Masters Men 70+")
        create_category(calculation, "Masters Women 50+")
        create_category(calculation, "Singlespeed Men")
        create_category(calculation, "Singlespeed Women")

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      Competitions::WillametteValleyClassicsTour::Overall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          event_notes: "Rules before 2020 may not be accurate",
          key: :willamette_valley_classic,
          name: competition.name,
          double_points_for_last_event: true,
          points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          year: competition.year
        )

        competition = convert_event(competition, calculation)
        move_results(competition)
      end

      execute "update events set type='Event' where type='CombinedTimeTrialResults'"
    end
  end

  def bar_event_notes
    <<~HTML
    <p>Oregon Best All-Around Rider (BAR) a year-round, multi-discipline competition open to annual members. Points and ranking will be tracked in at least the following categories: Senior Men and Women, Category 3 Men, Category 4/5 Men, Category 3 Women, Category 4/5 Women, Masters Men and Women, Junior Men and Women, Singlespeed/Fixed, Tandem, Clydesdale, Athena.</p>

    <p>There are separate discipline rankings, one each for Road, Track, Criterium, Time Trial, Cyclocross, Mountain Biking (Cross-country, Downhill, SuperD), Short Track, and Gravel. Points are awarded for finishes at all OBRA races for the top-15 in each discipline: 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1.</p>

    <p>State championships and national-caliber races are awarded double points. Fields with more than 75 riders are awarded 1.5 times regular BAR points.</p>

    <p>Points earned in team events are split evenly across the team members. Example: the winners of a three-person team time trial will each receive five points.</p>

    <p>Tandem teams earn points as a team. Tandem points do not count toward individual rider points.</p>

    <p>If a rider has multiple finishes in a single event, only the best finish counts. </p>

    <p>If a rider has multiple discipline rankings that would count towards the same overall category, only the best ranking counts.</p>

    <p>Weeknight events will accrue points for each month of racing.</p>

    <p>Points are tallied and riders are ranked in order of points in each discipline. The rider with the highest point tally in each discipline is awarded 300 "ranking" points, the rider with the second highest is awarded 299, third gets 298, etc. If a rider has points in more than five disciplines, only the top five disciplines are counted. This means that there is a total 1500 points possible.</p>

    <p>These ranking numbers are then added to determine annual awards. Riders must compete in a minimum of four disciplines in order to qualify for  annual trophies.</p>

    <p>The Team BAR is awarded based on the sum of the accrued points before rankings.</p>
    HTML
  end

  def convert_event(competition, calculation)
    link_source_events(competition, calculation)

    if competition.kind_of?(Competitions::Overall)
      event = competition.parent
      event.notes = calculation.event_notes if event.notes.blank?
      calculation.event = event
      calculation.save!
      Race.where(event_id: competition.id).update_all(event_id: event.id)
      Result.where(event_id: competition.id).update_all(event_id: event.id)
      competition.destroy!
    else
      competition.update_column :type, "Event"
      competition = Event.find(competition.id)
      calculation.event = competition
      competition.notes = calculation.event_notes if competition.notes.blank?
      calculation.save!
    end
    competition
  end

  def create_category(calculation, name, attributes = {})
    calculation.calculation_categories.create!(category: Category.find_or_create_by_normalized_name(name), **attributes)
  end

  def link_source_events(competition, calculation)
    competition.competition_event_memberships.each do |membership|
      calculation.calculations_events.create! event_id: membership.event_id, multiplier: membership.points_factor
    end
  end

  def move_results(competition)
    competition.races.each do |race|
      race.results.each do |result|
        result.scores.each do |score|
          ::ResultSource.create!(
            calculated_result_id: result.id,
            created_at: score.created_at,
            points: score.points,
            source_result_id: score.source_result_id,
            updated_at: score.updated_at
          )
        end
        result.scores.delete_all
      end
    end
  end

  def oregon_cup_notes
    <<~HTML
    <p>The Oregon Cup is a year-long points series for senior men.</p>
    <h3>Rules</h3>
    <ul id="rules">
      <li>Divisions: Senior 1/2 Men. </li>
      <li>Events selected by OBRA Oregon Cup Committee based on Race Selection Criteria (below). </li>
      <li>There is not a minimum number of races to qualify. </li>
      <li>Cash Prize List &ndash; 5 deep. </li>
        <ol>
          <li>$300</li>
          <li>$200</li>
          <li>$150</li>
          <li>$100</li>
          <li>$50</li>
        </ol>
      <li>Prizes awarded at the annual OBRA Banquet</li>
      <li>Leaders and champions jerseys will be awarded. </li>
      <li>The OBRA Oregon Cup Committee will conduct ongoing outreach to potential sponsors and media. </li>
      <li>Free entry to OR Cup events for OR Cup leaders. </li>
      <li>Lower category riders competing in Senior Men races will receive
      points unless their category is picked separately. Lower-category riders <b>do</b>
      still count in individual race placings -- if a lower category rider finishes
      ahead of a higher category rider, the higher category rider does not move up
      in their placing.</li>
      <li>Only yearly OBRA members are eligible for the Oregon Cup. People who only
      purchase one-day licenses will not be counted.</li>
      <li>Ties
        <ul>
          <li>The most first place finishes or, if still tied, the most second place finishes, etc., or if still tied;</li>
          <li>The highest placing in the last race, or the race nearest the last race in which at least one of the tied riders placed.</li>
        </ul>
      </li>
    </ul>

    <h3>Points</h3>
    <ol type="1">
      <li>100</li>
      <li>75</li>
      <li>60</li>
      <li>50</li>
      <li>45</li>
      <li>40</li>
      <li>35</li>
      <li>30</li>
      <li>25</li>
      <li>20</li>
      <li>19</li>
      <li>18</li>
      <li>17</li>
      <li>16</li>
      <li>15</li>
      <li>14</li>
      <li>13</li>
      <li>12</li>
      <li>11</li>
      <li>10</li>
    </ol>

    <h3>Race Selection Criteria</h3>
    <ol type="1">
      <li>No more than eight events. </li>
      <li>Primarily road races. Criteriums will be used as needed to fill schedule. </li>
      <li>Road Race Difficulty Balance - Balance degree of difficulty based on hills vs. flat, distance, etc. </li>
      <li>High Profile Event - Well advertised in advance both with membership and media. High likelihood of commercial sponsorship. </li>
      <li>Geographically Balanced - Southern, central and northwest Oregon based on membership representation. </li>
      <li>Historically Significant - History of success over many seasons. </li>
      <li>Demonstrated Participation - Popular event and/or venue. </li>
      <li>Seasonally Balanced - Monthly, if possible, March through September. </li>
      <li>Quality Venue/Promotion - Highest standards for promoters and OBRA. </li>
    </ol>

    <p>Questions? Contact <a href="mailto:srbeards@gmail.com" class="obvious">Steven Beardsley</a>.</p>
    HTML
  end
end
