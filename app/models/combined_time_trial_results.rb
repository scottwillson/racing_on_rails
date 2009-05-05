# All categories' results in a time trial by time
# TODO Combine with Competition. Really a special-case of Competition
class CombinedTimeTrialResults < Event
  after_create :calculate!
  validates_uniqueness_of :parent_id, :message => "Event can only have one CombinedTimeTrialResults"
  validate { |combined_results| combined_results.combined_results.nil? }

  def default_ironman
    ironman
  end

  def ironman
    false
  end
  
  def default_bar_points
    bar_points
  end

  def bar_points
    0
  end

  def default_name
    name
  end
  
  def name
    "Combined"
  end

  def discipline
    "Time Trial"
  end

  # TODO organize by race distance
  # TODO Consolidate approach with MTB combined results
  def calculate!
    return unless parent.notification?
    logger.debug("CombinedTimeTrialResults Recalculate")
    combined_race = recreate_races
    parent.races.each do |race|
      race.results.each do |result|
        if result.place.to_i > 0 && result.time && result.time > 0
          combined_race.results.create(
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
    combined_race.results.each do |result|
      result.update_attribute(:place, place.to_s)
      place = place + 1
    end
    self
  end

  def recreate_races
    destroy_races
    combined_category = Category.find_or_create_by_name("Combined")
    self.races.create(:category => combined_category)
  end
  
  def calculate_combined_results?
    false
  end
  
  def requires_combined_results?
    false
  end
  
  # Do nothing -- combined_results do not have combined_results
  def create_or_destroy_combined_results
    true
  end
end
