# Senior Men, Pro 1/2, Novice Masters 45+
#
# There are two kinds of categories: Association and BAR. Association categories are designated by
# OBRA, USA Cycling, WSBA, etc. and used in race results. BAR categories are used to categorize 
# results for the Best All-round Rider competition.
#
# Categories are basically labels and there is no complex hierarchy. In other words, Senior Men Pro 1/2 and
# Pro 1/2 are two distinct categories. They are not combinations of Pro and Senior and Men and Cat 1
##
# Categories are organized by 'scheme' -- Association or BAR. We might use 'type' and
# have subclasses, but we don't need separate subclasses for different Associations.
# Though, is it useful to have different schemes for different associations?
#
# By default, scheme is set to ASSOCIATION.short_name
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

  # has_many :competition_categories do
  #   def create_unless_exists(attributes)
  #     _attributes = attributes.clone
  #     _attributes[:category] = @owner unless _attributes[:category]
  #     unless _attributes[:category] && _attributes[:category].is_a?(Category)
  #       raise ArgumentError, "Must provide 'category' of type Category, but was #{_attributes[:category]} of type #{_attributes[:category].class.name}"
  #     end
  #     if _attributes[:source_category]
  #       existing = find(:first, :conditions => ['competition_id = ? and category_id = ? and source_category_id = ?', 
  #                         nil, _attributes[:category].id, _attributes[:source_category].id])
  #     else
  #       existing = find(:first, :conditions => ['competition_id = ? and category_id = ?', 
  #                         nil, _attributes[:category].id])
  #     end
  #     return existing unless existing.nil?
  #     create(_attributes)
  #   end
  # end
 
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
