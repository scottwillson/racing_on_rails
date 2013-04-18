# Sum all of Team's discipline BAR's results
# team = source_result.team
class TeamBar < Competition
  include Concerns::Bar::Categories
  include Concerns::Bar::Discipline

  after_create :set_parent

  def source_results(race)
    # Join team with outer join to calculate team size correctly
    results = Result.connection.select_all(
    %Q{
      select distinct results.id, scores.points as points, results.team_id as participant_id, results.race_name as category_name, member, results.team_name,
        results.place, results.event_id, results.race_id, results.date, results.year
      from results
      join scores on scores.source_result_id = results.id
      join results as competition_results on competition_results.id = scores.competition_result_id
      join events as competition_events on competition_events.id = competition_results.event_id 
      join teams on results.team_id = teams.id 
      where results.id = scores.source_result_id 
        and competition_events.type = 'Bar'
        and competition_results.year = #{year}
    }
    )
    
    results.each do |result|
      member = result.delete("member")
      if member == 1
        result["member_from"] = Date.new(year)
        result["member_to"] = Date.new(year, 12, 31)
      end
    end
    
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

  # Similar to superclass's method, except this method only saves results to the database. Superclass applies rules 
  # and scoring, but . It also decorates the results with any display data (often denormalized)
  # like people's names, teams, and points.
  def create_competition_results_for(results, race)
    results.each do |result|
      competition_result = Result.create!(
        :place                   => result.place,
        :team_id                 => result.participant_id,
        :event                   => self,
        :race                    => race,
        :competition_result      => true,
        :team_competition_result => true,
        :points                  => result.points
      )
       
      result.scores.each do |score|
        create_score competition_result, score.source_result_id, score.points
      end
    end

    true
  end

  # This is always the 'best' result
  def create_score(competition_result, source_result_id, points)
    Score.create!(
      :source_result_id => source_result_id, 
      :competition_result_id => competition_result.id, 
      :points => points
    )
  end

  def set_parent
    if parent.nil?
      self.parent = OverallBar.find_or_create_for_year(year)
      save!
    end
  end

  def results_per_event
    Competitions::Calculator::UNLIMITED
  end

  def use_source_result_points?
    true
  end

  def default_discipline
    "Team"
  end

  def friendly_name
    "Team BAR"
  end
end
