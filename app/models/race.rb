# A Race is essentionally a collection of Results labelled with a Category. Races must belong to a parent Event.
#
# Races only have some of their attributes populated. These attributes are listed in the +result_columns+ Array.
#
# People use say "category" where we use Race in code. Could rename this EventCategory.
#
# Race +result_columns+: populated columns displayed on results page. Usually Result attributes, but also creates
# virtual "custom" columns.
class Race < ActiveRecord::Base

  include Comparable
  include Export::Races
  include RacingOnRails::VestalVersions::Versioned
  include Sanctioned

  DEFAULT_RESULT_COLUMNS = %W{ place number last_name first_name team_name points time }.freeze
  RESULT_COLUMNS = %W{
    age age_group category_class category_name city date_of_birth first_name gender laps last_name license notes
    number place points points_bonus points_bonus_penalty points_from_place points_penalty points_total state
    team_name time time_bonus_penalty time_gap_to_leader time_gap_to_previous time_gap_to_winner time_total
  }.freeze

  validates_presence_of :event, :category

  before_validation :find_associated_records

  before_save :symbolize_custom_columns

  belongs_to :category
  belongs_to :event, inverse_of: :races
  has_one :promoter, through: :event
  has_many :results, dependent: :destroy

  serialize :result_columns, Array
  serialize :custom_columns, Array

  scope :include_results, -> { includes(:category, { results: :team })}
  scope :year, ->(year) { where(date: Time.zone.local(year).beginning_of_year.to_date..Time.zone.local(year).end_of_year.to_date) }

  default_value_for(:result_columns) { DEFAULT_RESULT_COLUMNS.dup }
  default_value_for :custom_columns, []

  # Defaults to Event's BAR points
  def bar_points
    self[:bar_points] || event.bar_points
  end

  # 0..3
  def bar_points=(value)
    if value.nil? || value == event.try(:bar_points)
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
      self.category = Category.new(name: name)
    end
    category.try :name
  end

  def discipline
    self.event.discipline if event
  end

  def category_name
    category.try :name
  end

  def category_friendly_param
    category.try :friendly_param
  end

  def name
    self.category_name
  end

  # Combine with event name
  def full_name
    if name == event.full_name
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
    event.try :date
  end

  def year
    event && event.date && event.date.year
  end

  # Incorrectly doubles tandem and other team events' field sizes
  def field_size
    if self[:field_size].present? && self[:field_size] > 0
      self[:field_size]
    else
      results.size
    end
  end

  def sanctioned_by
    self[:sanctioned_by] || event.try(:sanctioned_by) || RacingAssociation.current.default_sanctioned_by
  end

  def present_columns
    columns = []
    results.each do |result|
      (RESULT_COLUMNS + result.custom_attributes.keys).each do |result_column|
        value = result.send(result_column)
        if value.present? && value != 0 && value != 0.0 && value != "0" && value != "0.0"
          columns << result_column
        end
      end
    end
    columns.compact.map(&:to_s).uniq.sort
  end

  def set_result_columns!
    self.result_columns = present_columns
    save!
  end

  def result_columns=(value)
    _result_columns = value.dup

    if _result_columns && _result_columns.include?("name")
      name_index = _result_columns.index("name")
      _result_columns[name_index] = "first_name"
      _result_columns.insert(name_index + 1, "last_name")
    end

    if _result_columns && _result_columns.include?("place") && _result_columns.first != "place"
      _result_columns.delete("place")
      _result_columns.insert(0, "place")
    end
    self[:result_columns] = _result_columns
  end

  # Default columns if empty
  def result_columns_or_default
    self.result_columns ||= DEFAULT_RESULT_COLUMNS.dup
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
    columns << "bar" #if RacingAssociation.current.competitions.include?(:bar)
    columns.uniq!
    columns
  end

  def custom_columns
    self[:custom_columns] ||= []
  end

  def symbolize_custom_columns
    self.custom_columns.map! { |col| col.to_s.to_sym }
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
    if row_hash["place"].present? && row_hash["place"] != "1" && row_hash["place"] != "0"
      return true
    end
    if row_hash["person.first_name"].blank? &&
       row_hash["person.last_name"].blank? &&
       row_hash["person.road_number"].blank? &&
       row_hash["team.name"].blank?
      return false
    end
    true
  end

  # Sort results by points, assign places
  def place_results_by_points(break_ties = true, descending = true)
    _results = results.to_a
    _results.sort! do |x, y|
      x.compare_by_points(y, break_ties)
    end

    if !descending
      _results.reverse!
    end

    _results.each_with_index do |result, index|
      if index == 0
        result.place = 1
      else
        if _results[index - 1].compare_by_points(result, break_ties) == 0
          result.place = _results[index - 1].place
        else
          result.place = index + 1
        end
      end

      result.update_column(:place, result.place) if result.place_changed?
    end
  end

  def place_results_by_time
    _results = results.to_a.sort do |x, y|
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

    _results.each_with_index do |result, index|
      if index == 0
        result.place = 1
      else
        if _results[index - 1].compare_by_time(result, true) == 0
          result.place = _results[index - 1].place
        else
          result.place = index + 1
        end
      end
      result.update_column(:place, result.place) if result.place_changed?
    end
  end

  def calculate_members_only_places!
    # count up from zero
    last_members_only_place = 0
    # assuming first result starting at zero+one (better than sorting results twice?)
    last_result_place = 0
    results.sort.each do |result|
      place_before = result.members_only_place.to_i
      result.members_only_place = ''
      if result.numeric_place?
        if result.member_result?
          # only increment if we have moved onto a new place
          last_members_only_place += 1 if (result.numeric_place != last_members_only_place && result.numeric_place !=last_result_place)
          result.members_only_place = last_members_only_place.to_s
        end
        # Slight optimization. Most of the time, no point in saving a result that hasn't changed
        result.update(members_only_place: result.members_only_place) if place_before != result.members_only_place
        # store to know when switching to new placement (team result feature)
        last_result_place = result.numeric_place
      end
    end
  end

  def create_result_before(result_id)
    if results.empty?
      return results.create(place: "1")
    end

    if result_id
      _results = results.sort
      result = Result.find(result_id)
      start_index = _results.index(result)
      (start_index..._results.size).each do |index|
        if _results[index].numeric_place?
          _results[index].update_attributes! place: _results[index].next_place
        end
      end

      results.create place: result.place
    else
      append_result
    end
  end

  def append_result
    results.create place: results.sort.last.next_place
  end

  def destroy_result(result)
    _results = results.sort
    start_index = _results.index(result) + 1
    (start_index..._results.size).each do |index|
      if _results[index].numeric_place?
        _results[index].place = _results[index].numeric_place - 1
        _results[index].save!
      end
    end
    result.destroy
  end

  def any_results?
    results.any?
  end

  # Helper method for as_json
  def sorted_results
    results.sort
  end

  def junior?
    category.junior?
  end

  # By category name
  def <=>(other)
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

  def inspect_debug
    puts "  #{to_s}"
    results(true).sort.each(&:inspect_debug)
  end

  def to_s
    "#<Race #{self.id} #{self[:event_id]} #{self[:category_id]} >"
  end
end
