module Competitions
  class CompetitionCategory < ActiveRecord::Base
    belongs_to :competition
    belongs_to :category
    belongs_to :source_category, :class_name => 'Category', :foreign_key => :source_category_id
    
    validates_presence_of :category_id
    validates_presence_of :source_category_id
    
    before_validation :set_source_category_if_nil
    
    # TODO Combine with similar mwthod in Competition
    def CompetitionCategory.create_unless_exists(attributes)
      if attributes[:source_category]
        existing = find(:first, :conditions => ['competition_id = ? and category_id = ? and source_category_id = ?', 
                          nil, attributes[:category].id, attributes[:source_category].id])
      else
        existing = find(:first, :conditions => ['competition_id = ? and category_id = ?', 
                          nil, attributes[:category].id])
      end
      return existing unless existing.nil?
      create(attributes)
    end
    
    def set_source_category_if_nil
      if source_category.nil?
        source_category = category
        # Not sure why this is required ...
        self.source_category_id = category.id
      end
    end
  end
end
