# All categories' results in a time trial by time
# Adds +combined_results+ if Time Trial Event.
# Destroy +combined_results+ if they exist, but should not
# TODO Combine with Competition. Really a special-case of Competition
class CombinedTimeTrialResults < Event
  before_save :set_mandatory_defaults
  after_create :calculate!
  validates_uniqueness_of :parent_id, :message => "Event can only have one CombinedTimeTrialResults"
  validate { |combined_results| combined_results.combined_results.nil? }

  def default_bar_points
    0
  end

  def default_discipline
    "Time Trial"
  end

  def default_ironman
    false
  end

  def default_name
    "Combined"
  end

  def enable_notification!
    false
  end

  def disable_notification!
    false
  end

  def set_mandatory_defaults
    self.bar_points = default_bar_points
    self.discipline = default_discipline
    self.ironman = default_ironman
    self.name = default_name
    self.auto_combined_results = false
    self.notification = false
    true
  end

  def self.create_or_destroy_for!(event)
    return event.combined_results unless event.notification_enabled?
    event.disable_notification!

    if destroy_combined_results?(event)
      destroy_combined_results(event)
    elsif requires_combined_results?(event)
      create_combined_results(event)
      destroy_combined_results(event) unless event.combined_results.has_results?
    end

    event.enable_notification!
    event.combined_results
  end

  def self.destroy_combined_results?(event)
    !requires_combined_results?(event) || (event.combined_results(true) && !event.combined_results.has_results?)
  end

  def self.destroy_combined_results(event)
    if event.combined_results
      event.combined_results.destroy_races
      event.combined_results(true).destroy
      event.combined_results = nil
    end
  end

  def self.requires_combined_results?(event)
    allows_combined_results?(event) && event.auto_combined_results? && event.has_results?(true)
  end
  
  def self.allows_combined_results?(event)
    event.discipline == "Time Trial"
  end

  def self.create_combined_results(event)
    event.create_combined_results unless event.combined_results
  end

  def calculate!
    destroy_races
    combined_race = races.create!(:category => Category.find_or_create_by_name("Combined"))
    parent.races.each do |race|
      race.results.each do |result|
        if result.place.to_i > 0 && result.time && result.time > 0
          combined_race.results.create!(
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
    true
  end
end
