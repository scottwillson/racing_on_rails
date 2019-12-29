# frozen_string_literal: true

class ConvertCompetitionsToCalculations < ActiveRecord::Migration[5.2]
  def up
    Calculations::V3::Calculation.reset_column_information
    transaction do
      Competitions::BlindDateAtTheDairyOverall.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          description: "Rules before 2020 may not be accurate",
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
          description: "Rules before 2020 may not be accurate",
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
          description: "Rules before 2020 may not be accurate",
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
          description: "Rules before 2020 may not be accurate",
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
          description: "Rules before 2020 may not be accurate",
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
          description: "Rules before 2020 may not be accurate",
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
          description: "Rules before 2020 may not be accurate",
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
          description: "Rules before 2020 may not be accurate",
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

      # Competitions::Ironman.all.each do |competition|
      #   puts "#{competition.year} #{competition.type}"
      #   calculation = Calculations::V3::Calculation.create!(
      #     description: "Rules before 2020 may not be accurate",
      #     key: :ironman,
      #     members_only: true,
      #     name: "Ironman",
      #     points_for_place: 1,
      #     year: competition.year
      #   )
      #
      #   competition = convert_event(competition, calculation)
      #   move_results(competition)
      # end
    end
  end

  def convert_event(competition, calculation)
    if competition.kind_of?(Competitions::Overall)
      event = calculation.add_event!
      Race.where(event_id: competition.id).update_all(event_id: event.id)
      Result.where(event_id: competition.id).update_all(event_id: event.id)
    else
      competition.update_column :type, "Event"
      competition = Event.find(competition.id)
      calculation.event = competition
      calculation.save!
    end
    competition
  end

  def create_category(calculation, name, attributes = {})
    calculation.calculation_categories.create!(category: Category.find_or_create_by_normalized_name(name), **attributes)
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
end


    # types = [
    #   CombinedTimeTrialResults,
    #   Competitions::AgeGradedBar,
    #   Competitions::Bar,
    #   Competitions::BlindDateAtTheDairyMonthlyStandings,
    #   Competitions::BlindDateAtTheDairyOverall,
    #   Competitions::BlindDateAtTheDairyTeamCompetition,
    #   Competitions::Cat4WomensRaceSeries,
    #   Competitions::Competition,
    #   Competitions::CrossCrusadeCallups,
    #   Competitions::CrossCrusadeOverall,
    #   Competitions::CrossCrusadeTeamCompetition,
    #   Competitions::DirtyCirclesOverall,
    #   Competitions::GrandPrixBradRoss::Overall,
    #   Competitions::GrandPrixBradRoss::TeamStandings,
    #   Competitions::Ironman,
    #   Competitions::OregonCup,
    #   Competitions::OregonJuniorCyclocrossSeries::Overall,
    #   Competitions::OregonJuniorCyclocrossSeries::Team,
    #   Competitions::OregonJuniorMountainBikeSeries::Overall,
    #   Competitions::OregonTTCup,
    #   Competitions::OregonWomensPrestigeSeries,
    #   Competitions::OregonWomensPrestigeTeamSeries,
    #   Competitions::OverallBar,
    #   Competitions::PortlandShortTrackSeries::MonthlyStandings,
    #   Competitions::PortlandShortTrackSeries::Overall,
    #   Competitions::PortlandShortTrackSeries::TeamStandings,
    #   Competitions::PortlandTrophyCup,
    #   Competitions::TaborOverall,
    #   Competitions::TeamBar,
    #   Competitions::ThrillaOverall,
    #   Competitions::WillametteValleyClassicsTour::Overall
    # ]
    # Competitions::Competition.year(year).where(type: types).each do |competition|
    #   puts competition.full_name
    # end
