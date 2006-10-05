  class Category < ActiveRecord::Base

  include CategorySupport
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
    
  def Category.find_obra(name)
    Category.find_by_name_and_scheme(name, "OBRA")
  end
    
  # Can't use join because of table name collisions in eager association loading
  def Category.find_obra_with_bar(name)
    category = find_obra(name)
    if category != nil
      category.bar_category = Category.find(category.bar_category_id)
    end
    category
  end
  
  def initialize(attributes = nil)
    super
    if scheme.blank?
      self.scheme = "OBRA"
    end
  end
  
  def to_s
    "<Category #{id} #{bar_category_id} #{position} #{name} #{scheme}>"
  end

end
