module Names
  module Nameable
    def self.included(base)
      base.class_eval do
        base.send :extend, ClassMethods      
      end

      base.before_save :add_name
    end

    module ClassMethods
    end
  
    def name(date_or_year = nil)
      return read_attribute(:name) unless date_or_year && !self.names.empty?
    
      # TODO Tune this
      if date_or_year.is_a? Integer
        year = date_or_year
      else
        year = date_or_year.year
      end
    
      # Assume names always sorted
      if year <= self.names.first.year
        return self.names.first.name
      elsif year >= self.names.last.year && year < Date.today.year
        return self.names.last.name
      end
    
      name_for_year = self.names.detect { |n| n.year == year }
      if name_for_year
        name_for_year.name
      else
        read_attribute(:name)
      end
    end

    # Remember names from previous years. Keeps the correct name on old results without creating additional teams.
    # TODO This is a bit naive, needs validation, and more tests
    def add_name
      last_year = Date.today.year - 1
      if !@old_name.blank? && results_before_this_year? && !self.names.any? { |name| name.year == last_year }
        self.names.create(:name => @old_name, :year => last_year)
      end
    end
  end
end
