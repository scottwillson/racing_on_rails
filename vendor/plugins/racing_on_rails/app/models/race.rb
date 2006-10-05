# TODO Use Discipline class, not String
class Race < ActiveRecord::Base

  include Comparable
  include Dirty
  include RaceSupport

  DEFAULT_RESULT_COLUMNS = %W{place number last_name first_name team_name points time}
  # Prototype Result used for checking valid column names
  RESULT = Result.new
  
  validates_presence_of :standings_id, :category_id
  validate :result_columns_valid?

  before_validation :find_associated_records
  
  belongs_to :category
  serialize :result_columns, Array
  belongs_to :standings
  has_many :results, :dependent => :destroy
  
  def bar_category
    category.bar_category if category
  end
  
  def bar_category_name
    category.bar_category.name if category and category.bar_category
  end
  
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
  
  # Default columns if empty
  def result_columns_or_default
    self.result_columns || DEFAULT_RESULT_COLUMNS
  end
  
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
        existing_category = Category.find_by_name_and_scheme(category.name, category.scheme)
        self.category = existing_category if existing_category
      end
    end
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
  
  def to_s
    "<Race #{id} #{self[:standings_id]} #{self[:category_id]} >"
  end
  
end
