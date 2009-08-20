class TaborOverall < Overall
  def TaborOverall.parent_name
    "Mt. Tabor Series"
  end

  def default_bar_points
    1
  end

  def create_races
    races.create!(:category => Category.find_or_create_by_name("Fixed Gear"))
    races.create!(:category => Category.find_or_create_by_name("Category 4 Women"))
    races.create!(:category => Category.find_or_create_by_name("Masters Women"))
    races.create!(:category => Category.find_or_create_by_name("Senior Women"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men"))
    races.create!(:category => Category.find_or_create_by_name("Category 4 Men"))
    races.create!(:category => Category.find_or_create_by_name("Category 5 Men"))
    races.create!(:category => Category.find_or_create_by_name("Category 3 Men"))
    races.create!(:category => Category.find_or_create_by_name("Senior Men"))
  end
  
  # By default, does nothing. Useful to apply rule like:
  # * Any results after the first four only get 50-point bonus
  # * Drop lowest-scoring result
  def after_create_competition_results_for(race)
    race.results.each do |result|
      if result.scores.size > 5
        result.scores.sort! { |x, y| y.points <=> x.points }
        lowest_score = result.scores.last
        result.scores.destroy(lowest_score)
        # Rails destroys Score in database, but doesn't update the current association
        result.scores(true)
      end
    end
  end
  
  def point_schedule
    [0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16, 15, 14, 13, 12, 11]
  end
  
  # Apply points from point_schedule, and split across team
  def points_for(source_result, team_size = nil)
    points = point_schedule[source_result.place.to_i].to_f
    if source_result.last_event?
      points = points * 2
    end
    points
  end
end
