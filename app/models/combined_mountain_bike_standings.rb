# OBRA combines Pro, Semi-Pro, Men and Pro, Expert Women into two sets of combined standings.
# The combined standings are used for the BAR. Combined results are placed by time. Results without times 
# are placed last in non-determinate order. (They should be placed by category and place)
class CombinedMountainBikeStandings < CombinedStandings
  
  def self.reset
    @@men_combined = nil
    @@women_combined = nil
  end

  def initialize(attributes = nil)
    super
    self.bar_points = source.bar_points
  end

  def discipline
    'Mountain Bike'
  end
  
  # Recreate combine results from source results. Also set source race BAR points to none
  def recalculate
    logger.debug("CombinedMountainBikeStandings recalculate")
    create_races if races(true).empty?
    for race in races
      race.results.clear unless race.results.empty?
      combined_results = []

      for source_race in source.races(true)
        # FIXME Nasty, poorly-tested
        if race.category.children == source_race.category || race.category.children.include?(source_race.category) ||
          race.category.children.any?{|first_children| first_children.children.include?(source_race.category)}
          combined_results = combined_results + source_race.results
          source_race.update_attribute(:bar_points , 0)
        end
      end
      
      if combined_results.any? { |result| result.time.to_i > 0 }
        combined_results.delete_if { |result| result.time.to_i == 0 }
      end
      
      combined_results = combined_results.stable_sort_by(:place).
                                          stable_sort_by(:category).
                                          stable_sort_by(:time).
                                          stable_sort_by(:laps, :desc).
                                          stable_sort_by(:distance, :desc)
      
      combined_results.each_with_index { |result, i|
        race.results.create!(:place => (i + 1), :racer => result.racer, :team => result.team, :time => result.time)
      }
    end
  end

  def create_races
    races.create(:category => men_combined)
    races.create(:category => women_combined)
  end
  
  def men_combined
    if !defined?(@@men_combined) || @@men_combined.nil?
      @@men_combined = Category.find_or_create_by_name('Pro, Semi-Pro Men')
      @@men_combined.children << Category.find_or_create_by_name('Pro Men')
      @@men_combined.children << Category.find_or_create_by_name('Semi-Pro Men')
    end
    @@men_combined
  end
  
  def women_combined
    if !defined?(@@women_combined) || @@women_combined.nil?
      @@women_combined = Category.find_or_create_by_name('Pro, Expert Women')
      @@women_combined.children << Category.find_or_create_by_name('Pro Women')
      @@women_combined.children << Category.find_or_create_by_name('Expert Women')
    end
    @@women_combined
  end
  
  def to_s
    "<CombinedStandings id '#{id}' event_id '#{self[:event_id]}' source_id '#{self[:source_id]}' '#{name}'>"
  end
end