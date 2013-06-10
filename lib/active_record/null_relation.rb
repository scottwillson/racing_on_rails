module ActiveRecord
  # = Active Record Null Relation
  class NullRelation < Relation
    def self.page(options)
      self
    end
    
    def self.total_pages
      0
    end
    
    def self.sort
      self
    end
    
    def self.each(&block)
      true
    end

    def exec_queries
      @records = []
    end
  end
end
