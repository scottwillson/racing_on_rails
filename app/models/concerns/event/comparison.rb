module Concerns
  module Event
    module Comparison
      extend ActiveSupport::Concern

      include Comparable
      
      module InstanceMethods
        def ==(other)
          if self.equal?(other)
            return true
          end

          if other.nil? || !other || new_record? || other.new_record?
            return false
          end

          id == other.id
        end

        def eql?(other)
          if self.equal?(other)
            return true
          end

          if other.nil? || !other || new_record? || other.new_record?
            return false
          end

          id == other.id
        end

        def <=>(other)
          return -1 if other.nil? || !other

          if date 
            if other.date
              return date <=> other.date
            else
              return -1
            end
          elsif other.date
            return 1
          end 

          unless new_record? || other.new_record?
            return id <=> other.id
          end

          0
        end
      end
    end
  end
end
