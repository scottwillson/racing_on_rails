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

  belongs_to :overall, :class_name => "Category", :foreign_key => "overall_id"
  belongs_to :bar_category, :class_name => "Category", :foreign_key => "bar_category_id"
  belongs_to :combined_bar_category, :class_name => "Category", :foreign_key => "combined_bar_category_id"
  
  has_many :results
  has_many :races
  # BAR categories have other categories mapped to them
  has_many :categories, :foreign_key => "bar_category_id"
  has_many :competition_categories do
    def create_unless_exists(attributes)
      _attributes = attributes.clone
      _attributes[:category] = @owner unless _attributes[:category]
      unless _attributes[:category] && _attributes[:category].is_a?(Category)
        raise ArgumentError, "Must provide 'category' of type Category, but was #{_attributes[:category]} of type #{_attributes[:category].class.name}"
      end
      if _attributes[:source_category]
        existing = find(:first, :conditions => ['competition_id = ? and category_id = ? and source_category_id = ?', 
                          nil, _attributes[:category].id, _attributes[:source_category].id])
      else
        existing = find(:first, :conditions => ['competition_id = ? and category_id = ?', 
                          nil, _attributes[:category].id])
      end
      return existing unless existing.nil?
      create(_attributes)
    end
  end
 
  validates_presence_of :name, :scheme
 
  acts_as_list
  
  NONE = Category.new(:name => "", :id => nil)
 
  # Find BAR category by name
  # :deprecated:
  def Category.find_bar(name)
    Category.find_by_name_and_scheme(name, "BAR")
  end
  
  # Category with scheme = ASSOCIATION.short_name
  def Category.find_association(name)
    Category.find_by_name_and_scheme(name, ASSOCIATION.short_name)
  end
    
  # Find category by name and populate BAR category
  # Can't use join because of table name collisions in eager association loading
  def Category.find_with_bar(name)
    category = find_association(name)
    if category && category.bar_category_id
      category.bar_category = Category.find(category.bar_category_id)
    end
    category
  end
  
  def initialize(attributes = nil)
    super
    if scheme.blank?
      self.scheme = ASSOCIATION.short_name
    end
  end
  
  # Does +source_category+ map to this ctageory for competitions?
  # Example: Senior Men includes Pro Men, Pro/1/2 Men, etc.
  # 
  # This method looks in the competition_categories table.
  # 
  # Competitions may have custom category mappings that this method ignores
  def include?(source_category)
    puts
    puts("include? #{self} #{source_category}")
    return true if self == source_category
    for competition_category in competition_categories
      puts("#{competition_category.source_category}")
      return true if competition_category.source_category == source_category
    end
    false
  end

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
    "<Category #{id} #{bar_category_id} #{position} #{name} #{scheme}>"
  end
end
