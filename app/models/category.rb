# Senior Men, Pro 1/2, Novice Masters 45+
# 
# FIXME This is out of date. Categories are now just a simple hierarchy of names
#
# There are two kinds of categories: Association and BAR. Association categories are designated by
# OBRA, USA Cycling, WSBA, etc. and used in race results. BAR categories are used to categorize 
# results for the Best All-round Rider competition.
#
# Categories are basically labels and there is no complex hierarchy. In other words, Senior Men Pro 1/2 and
# Pro 1/2 are two distinct categories. They are not combinations of Pro and Senior and Men and Cat 1
#
# BAR categories may belong to an Overall BAR category
#
# Combined BAR categories roll-up multiple discipline BAR categories into one (not currently used)
class Category < ActiveRecord::Base

  include Comparable
  include Dirty

  acts_as_list
  acts_as_tree
  
  has_many :results
  has_many :races
  
  before_validation { |record| record.friendly_param = record.to_friendly_param }
  before_save { |record| (record.friendly_param = record.to_friendly_param) unless record.friendly_param }

  validates_presence_of :name
  validates_presence_of :friendly_param
  validate :parent_is_not_self
   
  NONE = Category.new(:name => "", :id => nil)
  
  # All categories with no parent (except root 'association' category)
  def Category.find_all_unknowns
    Category.find(:all, :conditions => ['parent_id is null and name <> ?', ASSOCIATION.short_name])
  end
  
  def Category.find_by_friendly_param(param)
    category_count = Category.count(:conditions => ['friendly_param = ?', param])
    case category_count
    when 0
      nil
    when 1
      Category.find(:first, :conditions => ['friendly_param = ?', param])
    else
      raise AmbiguousParamException, "#{category_count} occurrences of #{param}"
    end
  end
  
  def parent_is_not_self
    if parent_id && parent_id == id
      errors.add('parent', 'Category cannot be its own parent')
    end
  end
  
  # Default to blank
  def name
    self[:name] || ''
  end
  
  def short_name
    self[:name].gsub('Senior', 'Sr').gsub('Masters', 'Mst').gsub('Junior', 'Jr').gsub('Category', 'Cat').gsub('Beginner', 'Beg').gsub('Expert', 'Exp')
  end
  
  def ages
    self.ages_begin..ages_end
  end
  
  def ages=(value)
    self.ages_begin = value.begin
    self.ages_end = value.end
  end
  
  def descendants
    _descendants = children(true)
    for child in children
      _descendants = _descendants + child.descendants
    end
    _descendants
  end

  # Compare by position, then by name
  # TODO Need this method?
  def <=>(other)
    return 0 if self[:id] and self[:id] == other[:id]
    diff = (position <=> other.position)
    if diff == 0
      name <=> other.name
    else
      diff
    end
  end
    
  def to_friendly_param
    self.name.underscore.gsub('+', '_plus').gsub(/[^\w]+/, '_').gsub(/^_/, '').gsub(/_$/, '').gsub(/_+/, '_')
  end

  def to_s
    "#<Category #{id} #{parent_id} #{position} #{name}>"
  end
end

class AmbiguousParamException < Exception
end
