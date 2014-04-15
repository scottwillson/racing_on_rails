class AddCompetitionsClassPrefix < ActiveRecord::Migration
  def change
    %w{
      AgeGradedBar
      Bar
      BlindDateAtTheDairyOverall
      Cat4WomensRaceSeries
      Competition
      CrossCrusadeCallups
      CrossCrusadeOverall
      CrossCrusadeTeamCompetition
      MbraBar
      MbraTeamBar
      Ironman
      OregonTTCup
      OregonCup
      OregonJuniorCyclocrossSeries
      OregonWomensPrestigeSeries
      OregonWomensPrestigeTeamSeries
      Overall
      OverallBar
      RiderRankings
      TaborOverall
      TeamBar
      WsbaBarr
      WsbaMastersBarr
    }.each do |class_name|
      execute "update events set type='Competitions::#{class_name}' where type='#{class_name}'"
    end
  end
end
