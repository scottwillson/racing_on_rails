module Competitions
  # Sum all of Team's discipline BAR's results
  # team = source_result.team
  class TeamBar < Competition
    include Competitions::Bars::Categories
    include Competitions::Bars::Discipline
    include Competitions::Calculations::CalculatorAdapter

    after_create :set_parent

    def source_results(race)
      # Join team with outer join to calculate team size correctly
      results = Result.connection.select_all(
      %Q{
        select distinct results.id, scores.points as points, results.team_id as participant_id, results.race_name as category_name, results.team_member, results.team_name,
          results.place, results.event_id, results.race_id, results.date, results.year,
          people.member_from, people.member_to
        from results
        join scores on scores.source_result_id = results.id
        join results as competition_results on competition_results.id = scores.competition_result_id
        join events as competition_events on competition_events.id = competition_results.event_id
        left outer join people on people.id = results.person_id
        join teams on results.team_id = teams.id
        where results.id = scores.source_result_id
          and competition_events.type = 'Competitions::Bar'
          and competition_results.year = #{year}
      }
      )

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
