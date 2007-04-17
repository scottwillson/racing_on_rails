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

  validates_presence_of :name
   
  NONE = Category.new(:name => "", :id => nil)
  
  # All categories with no parent (except root 'association' category)
  def Category.find_all_unknowns
    Category.find(:all, :conditions => ['parent_id is null and name <> ?', ASSOCIATION.short_name])
  end
  
  # Default to blank
  def name
    self[:name] || ''
  end
  
  # Default to 9999
  def position
    self[:position] || 9999
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
    
  def to_s
    "#<Category #{id} #{parent_id} #{position} #{name}>"
  end
end
