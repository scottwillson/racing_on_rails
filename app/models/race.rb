# A Race is essentionally a collection of Results labelled with a Category. Races must belong to a parent Standings,
# and Standings must belong to a SingleDayEvent or a Competition.
# TODO Use Discipline class, not String
#
#  Races only have some of their attributes populated. These attributes are listed in the +result_columns+ Array
class Race < ActiveRecord::Base

  include Comparable
  include Dirty

  DEFAULT_RESULT_COLUMNS = %W{place number last_name first_name team_name points time}.freeze
  # Prototype Result used for checking valid column names
  RESULT = Result.new
  
  validates_presence_of :standings_id, :category_id
  validate :result_columns_valid?

  before_validation :find_associated_records
  
  belongs_to :category
  serialize :result_columns, Array
  belongs_to :standings
  has_many :results, :dependent => :destroy
  
  # :deprecated:
  def bar_category
    category.parent || category
  end
  
  # Convenience method to get the Race's Category's BAR Category
  # :deprecated:
  def bar_category_name
    category.parent.name if category and category.parent
  end
  
  # Defaults to Standings' BAR points
  def bar_points
    self[:bar_points] || standings.bar_points
  end
  
  def bar_points=(value)
    if value == standings.bar_points or value.nil?
      self[:bar_points] = nil
    elsif value.to_i == value.to_f
      self[:bar_points] = value
    else
      raise ArgumentError, "BAR points must be an integer, but was: #{value}"
    end
  end

  def category_name=(name)
    if name.blank?
      self.category = nil
      self.category.dirty
    else
      self.category = Category.new(:name => name)
    end
  end
  
  def name
    category.name if category
  end
  
  def date
    if standings || standings(true)
      standings.date
    end
  end
  
  # FIXME: Incorrectly doubles tandem and other team events' field sizes
  def field_size
    if self[:field_size] and self[:field_size] > 0
      self[:field_size]
    else
      results.size
    end
  end
  
  # Default columns if empty
  def result_columns_or_default
    self.result_columns || DEFAULT_RESULT_COLUMNS.clone
  end
  
  # Are there are +result_columns+ that don't map to a Result attribute
  def result_columns_valid?
    return if self.result_columns.nil?
    for column in self.result_columns
      if column.blank? or !RESULT.respond_to?(column.to_sym)
        errors.add('result_columns', "'#{column}' is not a valid result column")
      end
    end
  end
  
  def before_destroy
    results.clear
  end
  
  # Ensure child team and racers are not duplicates of existing records
  # Tricky side effect -- external references to new association records
  # (category, bar_category, racer, team) will not point to associated records
  # FIXME Handle racers with only a number
  def find_associated_records
    if category and (category.new_record? or category.dirty?)
      if category.name.blank?
        self.category = nil
      else
        existing_category = Category.find_by_name(category.name)
        self.category = existing_category if existing_category
      end
    end
  end
  
  def event
    standings.event
  end

  def has_result(row_hash)
    if !row_hash["place"].blank? and row_hash["place"] != "1" && row_hash["place"] != "0"
      return true
    end
    if row_hash["racer.first_name"].blank? and row_hash["racer.last_name"].blank? and row_hash["racer.road_number"].blank? and row_hash["team.name"].blank?
      return false
    end
    true
  end
  
  # Sort results by points, assign places
  # Save! each result after place is set
  def place_results_by_points(break_ties = true)
    for result in results
      result.calculate_points
    end

    results.sort! do |x, y| 
      x.compare_by_points(y)
    end

    previous_result = nil
    results.each_with_index do |result, index|
      if index == 0
        result.place = 1
      else
        if results[index - 1].compare_by_points(result, break_ties) == 0
          result.place = results[index - 1].place
        else
          result.place = index + 1
        end
      end
      result.save!
    end
  end
  
  # FIXME Almost certainly does not handle mixed member/non-member teams correctly
  def calculate_members_only_places!
    standings.event.disable_notification!
    begin
      non_members = 0
      for result in results.sort
        # Slight optimization. Most of the time, no point in saving a result that hasn't changed
        place_before = result.members_only_place
        result.members_only_place = ''
        if result.place.to_i > 0
          if result.racer.nil? or (result.racer and result.racer.member?(result.date))
            result.members_only_place = (result.place.to_i - non_members).to_s
          else
            non_members = non_members + 1
          end
        end
        result.update_attribute('members_only_place', result.members_only_place) if place_before != result.members_only_place
      end
    ensure
      standings.event.enable_notification!
    end
  end
  
  def <=>other
    category <=> other.category
  end

  def hash
    if new_record?
      category.hash
    else
      id
    end
  end

  def==(other)
    return false unless other.is_a?(self.class)
    unless other.new_record? or new_record?
      return other.id == id
    end
    category == other.category
  end

  def to_s
    "#<Race #{id} #{self[:standings_id]} #{self[:category_id]} >"
  end
end
