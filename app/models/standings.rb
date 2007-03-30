# Collection of Races (with hold Results). Normally, a SingleDayEvent has only one Standings that 
# has all the SingleDayEvent's Races. Additional Standings are used for:
# * Different time trial distances in the same event
# * Split stage race stages on the same day
# * Combined results for time trials and mountain bike races
# * Sprint and KOM competitions
#
# The word 'standings' is used imprecisely by racers and officials. Along with 'race, 'competition,'
# 'category,' this class imposes a somewhat arbritabry precision on a common term.
#
# Destryong a Standings destroys all of its child Races
class Standings < ActiveRecord::Base

  include Comparable
  
  validates_presence_of :event_id
  acts_as_list :scope => :event
  
  before_save :update_date, :update_discipline
  after_save :create_or_destroy_combined_standings
  
  belongs_to :event
  has_many :races, :dependent => :destroy
  has_one :combined_standings, 
          :foreign_key => 'source_id',
          :dependent => :destroy
  
  # TODO validate Event type
  # TODO Remove redundant date attribute -- it always should be equal to parent SingleDayEvent's date
  # TODO Move Event-specific methods to Event.standings.create
  def initialize(attributes = nil)
    super
    bar_points = bar_points || 1
    logger.debug("New #{to_s}") if logger.debug?
  end
  
  def bar_points
    read_attribute(:bar_points) || 1
  end
  
  def bar_points=(value)
    if value and value.to_i == value.to_f
      self[:bar_points] = value
    else
      raise ArgumentError, "BAR points must be an integer, but was: #{value}"
    end
  end
  
  def place_results_by_points(break_ties = true)
    for race in races
      race.place_results_by_points(break_ties)
    end
  end
  
  def race(category)
    return unless category
    for race in races
      if race.category and (category.name == race.category.name)
        return race
      end
    end
    return nil
  end
  
  # Returns only the Races with +results+
  def races_with_results
    races_copy = races.select {|race|
      !race.results.empty?
    }
    races_copy.sort!
    if combined_standings
      races_copy = races_copy + combined_standings.races.select {|race|
        !race.results.empty?
      }
    end
    races_copy
  end
  
  def discipline
    self[:discipline] || self.event.discipline if self.event
  end
  
  def update_discipline
    if event && self[:discipline] == event.discipline
      self[:discipline] = nil
    end
  end
  
  def date
    self[:date] || self.event.date if self.event
  end
  
  def short_date
    return '' unless date
    "#{date.month}/#{date.day}"
  end

  # Set date to the parent event's date
  def update_date
    self[:date] = self.event.date
  end
  
  def name
    self[:name] || self.event.name if self.event
  end

  # Adds +combined_standings+ if Mountain Bike or Time Trial Event. 
  # Destroy +combined_standings+ if they exist, but should not
  def create_or_destroy_combined_standings
    if !requires_combined_standings? or (combined_standings(true) and combined_standings.discipline != discipline)
      destroy_combined_standings
    end    
    if requires_combined_standings? and combined_standings(true).nil?
      if discipline == 'Mountain Bike'
        combined_standings = CombinedMountainBikeStandings.create!(:source => self)
      elsif discipline == 'Time Trial'
        combined_standings = CombinedTimeTrialStandings.create!(:source => self)
      end      
    end
    combined_standings(true)
  end
  
  # FIXME Just make a separate CompetitionStandings subclass
  def requires_combined_standings?
    (self.discipline == 'Mountain Bike' or self.discipline == 'Time Trial') and !(self.event.is_a?(Competition))
  end

  def destroy_combined_standings
    if combined_standings
      self.combined_standings.destroy
      self.combined_standings = nil
    end
  end
  
  # Let +combined_standings+ know that a result changed
  def after_result_save
    combined_standings.after_source_result_save if requires_combined_standings? and self.combined_standings
  end

  # Let +combined_standings+ know that a result was destroyed
  def after_result_destroy
    combined_standings.after_result_destroy if requires_combined_standings? and self.combined_standings
  end
  
  # Compare by position
  def <=>(other)
    self.position <=> other.position
  end

  def to_s
    "#<Standings '#{id}' '#{self[:event_id]}' '#{name}' '#{date}' #{discipline}>"
  end
end