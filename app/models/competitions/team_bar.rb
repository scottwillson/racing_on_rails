module Competitions
  # Sum all of Team's discipline BAR's results
  # team = source_result.team
  class TeamBar < Competition
    include Competitions::Bars::Categories
    include Competitions::Bars::Discipline
    include Competitions::Calculations::CalculatorAdapter

    after_create :set_parent
    
    def source_results_query(race)
      super.
      select("competition_events.type").
      select("scores.points as points").
      joins("join scores on scores.source_result_id = results.id").
      joins("join results as competition_results on competition_results.id = scores.competition_result_id").
      joins("join events as competition_events on competition_events.id = competition_results.event_id").
      where("competition_events.type" => "Competitions::Bar").
      where("competition_results.year" => year).
      where("results.id = scores.source_result_id")
    end
    
    def after_source_results(results)
      results_with_tandem_teams_split = []
      results.each do |result|
        category_name = result.delete("category_name")
        team_name = result.delete("team_name")
        if category_name["Tandem"] && team_name
          team_name.split("/").each do |n|
            team = Team.find_by_name_or_alias_or_create(n)
            results_with_tandem_teams_split << result.dup.merge("participant_id" => team.id)
          end
        else
          results_with_tandem_teams_split << result
        end
      end
      results_with_tandem_teams_split
    end

    def set_parent
      if parent.nil?
        self.parent = OverallBar.find_or_create_for_year(year)
        save!
      end
    end

    def results_per_race
      Competition::UNLIMITED
    end

    def results_per_event
      Competition::UNLIMITED
    end

    def use_source_result_points?
      true
    end

    def team?
      true
    end

    def default_discipline
      "Team"
    end

    def friendly_name
      "Team BAR"
    end
  end
end
