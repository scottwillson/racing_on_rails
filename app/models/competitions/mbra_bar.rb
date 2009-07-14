# MBRA Best All-around Rider Competition.
# Calculates a BAR for each Discipline
# The BAR categories and disciplines are all configured in the databsase. Race categories need to have a bar_category_id to 
# show up in the BAR; disciplines must exist in the disciplines table and discipline_bar_categories.
#
# This class implements a number of MBRA-specific rules.
# mbratodo: For example, riders upgrading during the season will take 1/2 of their points (up to 30 points max)
# with them to the higher category. The upgrading rider's accumulated points are allowed to stand at the
# lower category.
# After computing BAR results, look for Cat n BAR results for anyone in the Cat n - 1 BAR and add in half their Cat n points.
# cat 5 => cat 4 => cat 3 => cat 1/2
class MbraBar < Competition

  # TODO Add add_child(...) to Race
  # check placings for ties
  # remove one-day licensees
  
  validate :valid_dates

  def MbraBar.calculate!(year = Date.today.year)
    benchmark(name, Logger::INFO, false) {
      transaction do
        year = year.to_i if year.is_a?(String)
        date = Date.new(year, 1, 1)

        # Age Graded BAR and Overall BAR do their own calculations
        Discipline.find_all_bar.reject {|discipline| discipline == Discipline[:age_graded] || discipline == Discipline[:overall]}.each do |discipline|
          bar = MbraBar.find(:first, :conditions => { :date => date, :discipline => discipline.name })
          unless bar
            bar = MbraBar.create!(
              :name => "#{year} #{discipline.name} BAR",
              :date => date,
              :discipline => discipline.name
            )
          end
        end

        MbraBar.find(:all, :conditions => { :date => date }).each do |bar|
          bar.destroy_races
          bar.create_races
          bar.calculate_threshold_number_of_races
          bar.calculate!
        end
      end
    }
    # Don't return the entire populated instance!
    true
  end
  
  def MbraBar.find_by_year_and_discipline(year, discipline_name)
    MbraBar.find(:first, :conditions => { :date => Date.new(year), :discipline => discipline_name })
  end
  
  def calculate_threshold_number_of_races
    # 70% of the races (rounded to the nearest whole number) count in the BAR standings.
    @threshold_number_of_races = (Event.find_all_bar_for_discipline(self.discipline, self.date.year).size * 0.7).to_i
  end

  def point_schedule
    @point_schedule = @point_schedule || []
  end
  #  
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

  # Source result = counts towards the BAR "race" and BAR results
  # Example: Piece of Cake RR, 6th, Jon Knowlson
  #
  # bar_result, bar_race = BAR itself and placing in the BAR
  # Example: Senior Men BAR, 130th, Jon Knowlson, 45 points
  #
  # BAR results add scoring results as scores
  # Example: 
  # Senior Men BAR, 130th, Jon Knowlson, 18 points
  #  - Piece of Cake RR, 6th, Jon Knowlson 10 points
  #  - Silverton RR, 8th, Jon Knowlson 8 points
  def source_results(race)
    race_disciplines = "'#{race.discipline}'"
    category_ids = category_ids_for(race)

    Result.find(:all,
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
                :order => 'person_id'
      )
  end

#  def expire_cache
#    MbraBar.expire_cache
#  end
  
  # Apply points from point_schedule
  def points_for(source_result, team_size = nil)
    # TODO Consider indexing place
    # TODO Consider caching/precalculating team size
    # TODO Consider caching/precalculating point schedule
    calculate_point_schedule(source_result.race.field_size)
    points = 0
    MbraBar.benchmark('points_for') {
      if source_result.place.strip.downcase == "dnf"
        points = 0.5
      else
        # if multiple riders got the same place (must be a TTT?), then they split the points...
        team_size = team_size || Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
        points = point_schedule[source_result.place.to_i] * source_result.race.bar_points / team_size.to_f
      end
    }
    points
  end
  
  def after_create_competition_results_for(race)
    # 70% of the races (rounded to the nearest whole number) count in the
    # individual series standings. Riders who compete in more than 70% of the
    # races will throw out their weakest results.
    race.results.each do |result|
      # Don't bother sorting scores unless we need to drop some
      if result.scores.size > @threshold_number_of_races
        result.scores.sort! { |x, y| y.points <=> x.points }
        for lowest_score in result.scores[@threshold_number_of_races..(result.scores.size - 1)]
          result.scores.destroy(lowest_score)
        end
        # Rails destroys Score in database, but doesn't update the current association
        result.scores(true)
      end
    end
  end

  def create_races
    Discipline[discipline].bar_categories.each do |category|
      races.create!(:category => category)
    end
  end

  def members_only?
    false
  end

  def friendly_name
    'MBRA BAR'
  end

  def to_s
    "#<#{self.class.name} #{id} #{discipline} #{name} #{date}>"
  end

end
