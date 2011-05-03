# Senior Men, Pro 1/2, Novice Masters 45+
# 
# Categories are just a simple hierarchy of names
#
# Categories are basically labels and there is no complex hierarchy. In other words, Senior Men Pro 1/2 and
# Pro 1/2 are two distinct categories. They are not combinations of Pro and Senior and Men and Cat 1
#
# +friendly_param+ is used for friendly links on BAR pages. Example: senior_men
class Category < ActiveRecord::Base
  include Export::Categories

  include Comparable

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
    Category.all(
      :all, 
      :conditions => ['parent_id is null and name <> ?', RacingAssociation.current.short_name],
      :include => :children
     )
  end
  
  def Category.find_by_friendly_param(param)
    category_count = Category.count(:conditions => ['friendly_param = ?', param])
    case category_count
    when 0
      nil
    when 1
      Category.first(:conditions => ['friendly_param = ?', param])
    else
      raise AmbiguousParamException, "#{category_count} occurrences of #{param}"
    end
  end
  
  # Sr, Mst, Jr, Cat, Beg, Exp
  def Category.short_name(name)
    return name if name.blank?
    name.gsub('Senior', 'Sr').gsub('Masters', 'Mst').gsub('Junior', 'Jr').gsub('Category', 'Cat').gsub('Beginner', 'Beg').gsub('Expert', 'Exp').gsub("Clydesdale", "Clyd")
  end
  
  def parent_is_not_self
    if parent_id && parent_id == id
      errors.add 'parent', 'Category cannot be its own parent'
    end
  end
  
  # Default to blank
  def name
    self[:name] || ''
  end
  
  # Sr, Mst, Jr, Cat, Beg, Exp
  def short_name
    Category.short_name name
  end
  
  # Return Range
  def ages
    self.ages_begin..ages_end
  end
  
  # Accepts an age Range like 10..18, or a String like 10-18
  def ages=(value)
    case value
    when Range
      self.ages_begin = value.begin
      self.ages_end = value.end
    else
      age_split = value.strip.split('-')
      self.ages_begin = age_split[0].to_i unless age_split[0].nil?
      self.ages_end = age_split[1].to_i unless age_split[1].nil?
    end
  end
  
  # All children and children childrens
  def descendants
    _descendants = children(true)
    children.each do |child|
      _descendants = _descendants + child.descendants
    end
    _descendants
  end

  # Compare by position, then by name
  def <=>(other)
    return 0 if self[:id] and self[:id] == other[:id]
    diff = (position <=> other.position)
    if diff == 0
      name <=> other.name
    else
      diff
    end
  end
  
  # Lowercase underscore
  def to_friendly_param
    name.underscore.gsub('+', '_plus').gsub(/[^\w]+/, '_').gsub(/^_/, '').gsub(/_$/, '').gsub(/_+/, '_')
  end

  def to_s
    "#<Category #{id} #{parent_id} #{position} #{name}>"
  end
end

class AmbiguousParamException < Exception
end
