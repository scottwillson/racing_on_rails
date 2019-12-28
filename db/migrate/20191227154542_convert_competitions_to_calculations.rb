# frozen_string_literal: true

class ConvertCompetitionsToCalculations < ActiveRecord::Migration[5.2]
  def up
    transaction do
      Competitions::Ironman.all.each do |competition|
        puts "#{competition.year} #{competition.type}"
        calculation = Calculations::V3::Calculation.create!(
          key: :ironman,
          members_only: true,
          name: "Ironman",
          points_for_place: 1,
          year: competition.year
        )

        competition = convert_event(competition, calculation)
        move_results(competition)
      end
    end
  end

  def convert_event(competition, calculation)
    competition.update_column :type, "Event"
    competition = Event.find(competition.id)
    calculation.event = competition
    calculation.save!
    competition
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
