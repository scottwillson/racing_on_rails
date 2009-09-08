# A Race is essentionally a collection of Results labelled with a Category. Races must belong to a parent Event.
# TODO Use Discipline class, not String
#
# Races only have some of their attributes populated. These attributes are listed in the +result_columns+ Array.
class Race < ActiveRecord::Base

  include Comparable

  DEFAULT_RESULT_COLUMNS = %W{place number last_name first_name team_name points time}.freeze
  # Prototype Result used for checking valid column names
  RESULT = Result.new
  
  validates_presence_of :event, :category
  validate :result_columns_valid?

  before_validation :find_associated_records
  
  belongs_to :category
  serialize :result_columns, Array
  belongs_to :event
  has_many :results, :dependent => :destroy
  
  # Convenience method to get the Race's Category's BAR Category
  # :deprecated:
  def bar_category_name
    category.parent.name if category and category.parent
  end
  
  # Defaults to Event's BAR points
  def bar_points
    self[:bar_points] || self.event.bar_points
  end
  
  def bar_points=(value)
    if value == self.event.bar_points or value.nil?
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
    else
      self.category = Category.new(:name => name)
    end
  end
  
  def discipline
    self.event.discipline if event
  end
  
  def category_name
    category.name if category
  end
  
  def name
    self.category_name
  end
  
  def full_name
    if name == self.event.full_name
      name
    elsif event.full_name[name]
      event.full_name
    else
      "#{event.full_name}: #{name}"
    end
  end

  # Range of dates_of_birth of people in this race
  def dates_of_birth
    raise(ArgumentError, 'Need category to calculate dates of birth') unless category
    Date.new(date.year - category.ages.end, 1, 1)..Date.new(date.year - category.ages.begin, 12, 31)
  end
  
  def date
    raise(ArgumentError, 'Need Event to get date') unless self.event
    self.event.date
  end
  
  # FIXME: Incorrectly doubles tandem and other team events' field sizes
  def field_size
    if self[:field_size] and self[:field_size] > 0
      self[:field_size]
    else
      results.size
    end
  end

  def result_columns=(value)
    if value.include?("name")
      name_index = value.index("name")
      value[name_index] = "first_name"
      value.insert(name_index + 1, "last_name")
    end

    if value.include?("place") && value.first != "place"
      value.delete("place")
      value.insert(0, "place")
    end
    self[:result_columns] = value
  end
  
  # Default columns if empty
  def result_columns_or_default
    self.result_columns || DEFAULT_RESULT_COLUMNS.dup
  end
  
  # Ugh. Better here than a controller or helper, I guess.
  def result_columns_or_default_for_editing
    columns = result_columns_or_default
    columns.map! do |column| 
      if column == "first_name" || column == "last_name"
        "name"
      else
        column
      end
    end
    columns << "bar" if ASSOCIATION.competitions.include?(:bar)
    columns.uniq!
    columns
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
  
  # Ensure child team and people are not duplicates of existing records
  # Tricky side effect -- external references to new association records
  # (category, bar_category, person, team) will not point to associated records
  # FIXME Handle people with only a number
  def find_associated_records
    if category && (category.new_record? || category.changed?)
      if category.name.blank?
        self.category = nil
      else
        existing_category = Category.find_by_name(category.name)
        self.category = existing_category if existing_category
      end
    end
  end

  def has_result(row_hash)
    if !row_hash["place"].blank? and row_hash["place"] != "1" && row_hash["place"] != "0"
      return true
    end
    if row_hash["person.first_name"].blank? and row_hash["person.last_name"].blank? and row_hash["person.road_number"].blank? and row_hash["team.name"].blank?
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
  
  def calculate_members_only_places!
    event_notification_was_enabled = event.notification_enabled?
    event.disable_notification!
    begin
      last_members_only_place = 0 #count up from zero
      last_result_place = 0 #assuming first result starting at zero+one (better than sorting results twice?)
      results.sort.each do |result|
        place_before = result.members_only_place.to_i
        result.members_only_place = ''
        if result.place.to_i > 0         
          if ((result.person.nil? or (result.person and result.person.member?(result.date))) and not non_members_on_team(result))
            last_members_only_place+=1 if (result.place.to_i!=last_members_only_place && result.place.to_i!=last_result_place) #only increment if we have moved onto a new place
            result.members_only_place = last_members_only_place.to_s
          end
          result.update_attribute('members_only_place', result.members_only_place) if place_before != result.members_only_place # Slight optimization. Most of the time, no point in saving a result that hasn't changed
          last_result_place = result.place.to_i #store to know when switching to new placement (team result feature)
        end
      end
    ensure
      event.enable_notification! if event_notification_was_enabled
    end
  end
  
  def non_members_on_team(result)
    non_members = false
    exempt_cats = ASSOCIATION.exempt_team_categories #if this is undeclared in environment.rb, assume this rule does not apply
     if (exempt_cats.nil? or exempt_cats.include?(result.race.category.name))
       return non_members
     else
       other_results_in_place = Result.find(:all, :conditions => ["race_id = ? and place = ?", result.race.id, result.place])
       other_results_in_place.each { |orip|
          unless orip.person.nil?
            if not orip.person.member?(result.date)
             #might as well blank out this result while we're here, saves some future work
             result.members_only_place = ''
             result.update_attribute('members_only_place', result.members_only_place)
             non_members=true #could also use other_results_in_place.size if needed for calculations
            end
          end
       }
       return non_members #still false if no others found, or all are members, or could not be determined (non-person)
     end
   end
  
  def create_result_before(result_id)
    results.sort!
    if results.empty?
      return results.create(:place => "1")
    end
    
    if result_id
      result = Result.find(result_id)
    else
      result = results.last
    end
    
    place = result.place
    start_index = results.index(result)
    for index in start_index...(results.size)
      if results[index].place.to_i > 0
        results[index].place = (results[index].place.to_i + 1).to_s
        results[index].save!
      end
    end
    
    results.create(:place => place)
  end
  
  def destroy_result(result)
    place = result.place
    results.sort!
    start_index = results.index(result) + 1
    for index in start_index...(results.size)
      if results[index].place.to_i > 0
        results[index].place = results[index].place.to_i - 1
        results[index].save!
      end
    end
    result.destroy
  end
  
  def <=>other
    category.name <=> other.category.name
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
    "#<Race #{id} #{self[:event_id]} #{self[:category_id]} >"
  end
end
