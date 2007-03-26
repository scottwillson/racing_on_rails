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

  include Dirty

  acts_as_list
  acts_as_tree
  
  # :deprecated: Will be removed after migration
  belongs_to :bar_category, :class_name => "Category", :foreign_key => "bar_category_id"
  
  has_many :results
  has_many :races

  validates_presence_of :name
   
  NONE = Category.new(:name => "", :id => nil)

  def <=>(other)
    if other
      do1 = position || 9999
      do2 = other.position || 9999
      do1 <=> do2
    elsif !name.nil?
      name <=> other.name
    else
      -1
    end
  end
    
  def to_s
    "<Category #{id} #{parent_id} #{position} #{name}>"
  end
end
