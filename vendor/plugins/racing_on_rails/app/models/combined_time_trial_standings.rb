class CombinedTimeTrialStandings < CombinedStandings
  
  def initialize(attributes = nil)
    super
    self.bar_points = 0
  end

  def discipline
    'Time Trial'
  end

  # Return transient Standings with results from all races sorted by time
  # TODO organize by race distance
  # TODO Consolidate approach with MTB combined results
  def recalculate
    logger.debug("CombinedTimeTrialStandings Recalculate")
    combined_race = recreate_races
    for race in source.races
      for result in race.results
        if result.place.to_i > 0
          new_combined_result = combined_race.results.create(
            :racer => result.racer,
            :team => result.team,
            :time => result.time,
            :category => race.category
          )
        end
      end
    end
    combined_race.results.sort! do |x, y|
      if x.time
        if y.time
          x.time <=> y.time
        else
          1
        end
      else
        -1
      end
    end
    place = 1
    for result in combined_race.results
      result.update_attribute(:place, place.to_s)
      place = place + 1
    end
    combined_standings
  end

  def recreate_races
    self.races.clear
    combined_category = Category.new(:name => 'Combined')
    self.races.create(:category => combined_category)
  end
  
end