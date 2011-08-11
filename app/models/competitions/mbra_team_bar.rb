class MbraTeamBar < Competition
  
  def MbraTeamBar.calculate!(year = Date.today.year)
    benchmark(name, :level => :info) {
      transaction do
        year = year.to_i if year.is_a?(String)
        date = Date.new(year, 1, 1)

        # Maybe I will exclude MTB and CX if people are disturbed by it...but calc for now for fun.
        Discipline.find_all_bar.reject {|discipline| discipline == Discipline[:age_graded] || discipline == Discipline[:overall]}.each do |discipline|
          bar = MbraTeamBar.first(:conditions => { :date => date, :discipline => discipline.name })
          logger.debug("In MbraTeamBar.calculate!: discipline #{discipline}") if logger.debug?
          unless bar
            bar = MbraTeamBar.create!(
              :name => "#{year} #{discipline.name} BAT",
              :date => date,
              :discipline => discipline.name
            )
          end
        end

        MbraTeamBar.all( :conditions => { :date => date }).each do |bar|
          logger.debug("In MbraTeamBar.calculate!: processing bar #{bar.name}") if logger.debug?
          bar.destroy_races
          bar.create_races
          bar.calculate!
        end
      end
    }
    # Don't return the entire populated instance!
    true
  end

  def point_schedule
    @point_schedule = @point_schedule || []
  end
  
  # Riders obtain points inversely proportional to the starting field size,
  # plus bonuses for first, second and third place (6, 3, and 1 points respectively).
  # DNF: 1/2  point
  def calculate_point_schedule(field_size)
    @point_schedule = [0]
    field_size.downto(1) { |i| @point_schedule << i }
    @point_schedule[1] += 6 if @point_schedule.length > 1
    @point_schedule[2] += 3 if @point_schedule.length > 2
    @point_schedule[3] += 1 if @point_schedule.length > 3
  end

  # Find the source results from discipline BAR's competition results.
  # this does not work for mbra due to the 70%-of-events rule for bar that does not apply to bat
  def source_results(race)
    race_disciplines = "'#{race.discipline}'"
    category_ids = category_ids_for(race)
    Result.all(
                :include => [:race, {:person => :team}, :team, {:race => [{:event => { :parent => :parent }}, :category]}],
                :conditions => [%Q{
                    (events.type in ('Event', 'SingleDayEvent', 'MultiDayEvent') or events.type is NULL)
                    and bar = true
                    and categories.id in (#{category_ids})
                    and (events.discipline in (#{race_disciplines})
                      or (events.discipline is null and parents_events.discipline in (#{race_disciplines}))
                      or (events.discipline is null and parents_events.discipline is null and parents_events_2.discipline in (#{race_disciplines})))
                    and (races.bar_points > 0
                      or (races.bar_points is null and events.bar_points > 0)
                      or (races.bar_points is null and events.bar_points is null and parents_events.bar_points > 0)
                      or (races.bar_points is null and events.bar_points is null and parents_events.bar_points is null and parents_events_2.bar_points > 0))
                    and events.date between '#{date.year}-01-01' and '#{date.year}-12-31'
                }],
                :order => 'results.team_id, race_id'
      )
  end
  
  # create a competition_result for each team appearing in this set of results, which is per race
  def create_competition_results_for(results, race)
    competition_result = nil
    for source_result in results
      logger.debug("#{self.class.name} scoring result: #{source_result.event.name} | #{source_result.race.name} | #{source_result.place} | #{source_result.name} | #{source_result.team_name}") if logger.debug?
      # e.g., MbraTeamBar scoring result: Belt Creek Omnium - Highwood TT | Master A Men | 4 | Steve Zellmer | Northern Rockies Cycling

      # I don't need this now: no allowance for TTT or tandem teams with members of multiple teams
      #  teams = extract_teams_from(source_result)
      #  logger.debug("#{self.class.name} teams for result: #{teams}") if logger.debug?
      #  for team in teams

      if member?(source_result.team, source_result.date)

        if first_result_for_team(source_result, competition_result)
          # Bit of a hack here, because we split tandem team results into two results,
          # we can't guarantee that results are in team-order.
          # So 'first result' really means 'not the same as last result'
          # race here is the category in the competition
          competition_result = race.results.detect {|result| result.team == source_result.team}
          competition_result = race.results.create(:team => source_result.team) if competition_result.nil?
        end

        # limit to top two results for team for each source race by 
        # removing the lowest score for the event after every result.
        # I do it this way because results do not arrive in postion order.
        # SQL sorting does not work as position is a varchar field.
        score = competition_result.scores.create(
          :source_result => source_result,
          :competition_result => competition_result,
          :points => points_for(source_result).to_f #/ teams.size
        )
        this_points = score.points
        logger.debug("#{self.class.name} competition result: #{competition_result.event.name} | #{competition_result.race.name} | #{competition_result.place} | #{competition_result.team_name}") if logger.debug?
        # e.g., MbraTeamBar competition result: 2009 MBRA BAT | Master A Men |  | Gallatin Alpine Sports/Intrinsik Architecture
        scores_for_event = competition_result.scores.select{ |s| s.source_result.event.name == source_result.event.name}
        if scores_for_event.size > 2
          competition_result.scores.delete(scores_for_event.min { |a,b| a.points <=> b.points })
        end
      end
    end
  end

  def first_result_for_team(source_result, competition_result)
    competition_result.nil? || source_result.team != competition_result.team
  end

  # Apply points from point_schedule
  # Points are awarded using the same criteria as for individuals except that there
  # are no double points awarded for State Championships.
  def points_for(source_result, team_size = nil)
    calculate_point_schedule(source_result.race.field_size)
    points = 0
    MbraTeamBar.benchmark('points_for') {
      if source_result.place.strip.downcase == "dnf"
        points = 0.5
      else
        # if multiple riders got the same place (must be a TTT or tandem team or... ?), then they split the points...
        #this screws up the scoring of match sprints where riders eliminatined in qualifying heats all earn the same place
        #team_size = team_size || Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
        points = point_schedule[source_result.place.to_i] #/ team_size.to_f
      end
    }
      logger.debug("#{self.class.name} points: #{points} for #{source_result.event.name} | #{source_result.race.name} | #{source_result.place} | #{source_result.name} | #{source_result.team_name}") if logger.debug?
    points
  end

  def create_races
    logger.debug("In create_races: discipline #{discipline}") if logger.debug?
    Discipline[discipline].bar_categories.each do |category|
      logger.debug("In create_race: category #{category}") if logger.debug?
      races.create!(:category => category)
    end
  end

  def friendly_name
    'MBRA BAT'
  end
end
