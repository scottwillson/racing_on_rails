# WSBA rider rankings. Riders get points for top-10 finishes in any event
class RiderRankings < Competition
  # FIXME Need to exclude non-members from the standings
  
  def RiderRankings.expire_cache
    FileUtils::rm_rf("#{RAILS_ROOT}/public/rider_rankings.html")
    FileUtils::rm_rf("#{RAILS_ROOT}/public/rider_rankings")
  end

  def friendly_name
    'Rider Rankings'
  end

  def point_schedule
    [0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16]
  end

  # Apply points from point_schedule, and adjust for team size
  def points_for(source_result)
    team_size = Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
    points = point_schedule[source_result.members_only_place.to_i].to_f
    if points
      points / team_size
    else
      0
    end
  end
  
  def place_members_only?
    true
  end
  
  def create_standings
    root_standings = standings.create(:event => self)
    association_category = Category.find_or_create_by_name(ASSOCIATION.short_name)
    for category_name in [
      'Junior Men A', 'Junior Men B', 'Junior Men C', 'Junior Men D',
      'Junior Women A', 'Junior Women B', 'Junior Women C', 'Junior Women D',
      'Men Cat 1-2', 'Men Cat 3', 'Men Cat 4-5', 
      'Masters Men A', 'Masters Men B', 'Masters Men C', 
      'Masters Men D', 'Masters Women A', 'Masters Women B', 
      'Women Cat 1-2-3', 'Women Cat 4']

      category = Category.find_or_create_by_name(category_name)
      unless category.parent
        category.parent = association_category
        category.save!
      end
      root_standings.races.create(:category => category)
    end
  end

  # source_results must be in racer-order
  # TODO Probably should work with fully-populated Events instead
  def source_results(race)
    Result.find(:all,
                :include => [:race, {:racer => :team}, :team, {:race => [{:standings => :event}, :category]}],
                :conditions => [%Q{members_only_place between 1 AND #{point_schedule.size - 1}
                  and events.type = 'SingleDayEvent' 
                  and categories.id in (#{category_ids_for(race)})
                  and (races.bar_points > 0 or (races.bar_points is null and standings.bar_points > 0))
                  and events.date >= '#{date.year}-01-01' 
                  and events.date <= '#{date.year}-12-31'}],
                :order => 'racer_id'
    )
  end
  
  def member?(racer, date)
    racer && racer.member?(date)
  end
  
  def expire_cache
    RiderRankings.expire_cache
  end
end
