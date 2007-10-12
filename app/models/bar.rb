require 'fileutils'

# Best All-around Rider Competition. Assigns points for each top-15 placing in major Disciplines: road, track, etc.
# Calculates a BAR for each Discipline, and an Overall BAR that combines all the discipline BARs.
# Also calculates a team BAR.
# Recalculating the BAR at years-end can take nearly 30 minutes even on a fast server. Recalculation must be manually triggered.
# This class implements a number of OBRA-specific rules and should be generalized and simplified.
# The BAR categories and disciplines are all configured in the databsase. Race categories need to have a bar_category_id to 
# show up in the BAR; disciplines must exist in the disciplines table and discipline_bar_categories.
# FIXME This documentation is out of date
class Bar < Competition
  include FileUtils

  # TODO Add add_child(...) to Race
  # check placings for ties
  # remove one-day licensees
  
  validate :valid_dates
  
  # Expire BAR web pages from cache. Expires *all* BAR pages. Shouldn't be in the model, either
  # BarSweeper seems to fire, but does not expire pages?
  def Bar.expire_cache
    FileUtils::rm_rf("#{RAILS_ROOT}/public/bar.html")
    FileUtils::rm_rf("#{RAILS_ROOT}/public/bar")
  end

  def point_schedule
    [0, 30, 25, 22, 19, 17, 15, 13, 11, 9, 7, 5, 4, 3, 2, 1]
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
    if race.standings.discipline == 'Road'
      race_disciplines = "'Road', 'Circuit'"
    else
      race_disciplines = "'#{race.standings.discipline}'"
    end
    Result.find(:all,
                :include => [:race, {:racer => :team}, :team, {:race => [{:standings => :event}, :category]}],
                :conditions => [%Q{place between 1 AND #{point_schedule.size - 1}
                  and events.type in ('SingleDayEvent', 'MultiDayEvent', 'Series', 'WeeklySeries')
                  and categories.id in (#{category_ids_for(race)})
                  and (standings.discipline in (#{race_disciplines}) or (standings.discipline is null and events.discipline in (#{race_disciplines})))
                  and (races.bar_points > 0 or (races.bar_points is null and standings.bar_points > 0))
                  and events.date >= '#{date.year}-01-01' 
                  and events.date <= '#{date.year}-12-31'}],
                :order => 'racer_id'
      )
  end

  def expire_cache
    Bar.expire_cache
  end
  
  # Apply points from point_schedule, and adjust for field size
  def points_for(source_result, team_size = nil)
    # TODO Consider indexing place
    # TODO Consider caching/precalculating team size
    points = 0
    Bar.benchmark('points_for') {
      field_size = source_result.race.field_size

      team_size = team_size || Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
      points = point_schedule[source_result.place.to_i] * source_result.race.bar_points / team_size.to_f
      if source_result.race.standings.name['CoMotion'] and source_result.race.category.name == 'Category C Tandem'
        points = points / 2.0
      end
      if source_result.race.bar_points == 1 and field_size >= 75
        points = points * 1.5
      end
    }
    points
  end
  
  def create_standings
    raise errors.full_messages unless errors.empty?
    for discipline in Discipline.find_all_bar
      discipline_standings = standings.create(
        :name => discipline.name,
        :discipline => discipline.name
      )
      raise(RuntimeError, discipline_standings.errors.full_messages) unless discipline_standings.errors.empty?
      for category in discipline.bar_categories
        race = discipline_standings.races.create(:category => category)
        raise(RuntimeError, race.errors.full_messages) unless race.errors.empty?
      end
    end
  end

  def friendly_name
    'BAR'
  end

  def to_s
    "#<#{self.class.name} #{id} #{discipline} #{name} #{date}>"
  end
end
