  class Category < ActiveRecord::Base

  include Dirty

  belongs_to :overall, :class_name => "Category", :foreign_key => "overall_id"
  belongs_to :bar_category, :class_name => "Category", :foreign_key => "bar_category_id"
  belongs_to :combined_bar_category, :class_name => "Category", :foreign_key => "combined_bar_category_id"
  has_many :results
 
  validates_presence_of :name, :scheme
 
  acts_as_list
  
  NONE = Category.new(:name => "", :id => nil)
 
  def Category.find_bar(name)
    Category.find_by_name_and_scheme(name, "BAR")
  end
    
  def Category.find_association(name)
    Category.find_by_name_and_scheme(name, ASSOCIATION.short_name)
  end
    
  # Can't use join because of table name collisions in eager association loading
  def Category.find_with_bar(name)
    category = find_association(name)
    if category != nil
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
