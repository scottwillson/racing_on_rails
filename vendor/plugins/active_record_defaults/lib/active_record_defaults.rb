module ActiveRecord
  module Defaults
    def self.included(base)
      base.extend ClassMethods
      base.send(:include, InstanceMethods)
      
      base.send :alias_method, :initialize_without_defaults, :initialize
      base.send :alias_method, :initialize, :initialize_with_defaults
    end
    
    module ClassMethods
      # Define default values for attributes on new records. Requires a hash of <tt>attribute => value</tt> pairs.
      # The value can be a specific object, like a string or an integer, or a Proc that returns the default value when called.
      # 
      #   class Person < ActiveRecord::Base
      #     defaults :name => 'My name', :city => Proc.new { 'My city' }
      #   end
      #   
      # The default values are only used if the key is not present in the given attributes.
      # 
      #   p = Person.new
      #   p.name # "My name"
      #   p.city # "My city"
      #   
      #   p = Person.new(:name => nil)
      #   p.name # nil
      #   p.city # "My city"
      def defaults(attribute_values = {})
        write_inheritable_array :attribute_defaults, attribute_values.map { |attribute, value| Default.new(attribute, value) }
      end
      
      # An arguably nicer syntax for specifying a single default that is defined by a block
      # 
      # Instead of:
      # 
      #   class Person < ActiveRecord::Base
      #     defaults :name => Proc.new { |person|
      #       # code here
      #     }
      #   end
      #   
      #   class Person < ActiveRecord::Base
      #     default :name do |person|
      #       # code here
      #     end
      #   end
      def default(attribute, &block)
        defaults attribute => block
      end
    end
    
    module InstanceMethods
      def initialize_with_defaults(attributes = nil)
        initialize_without_defaults(attributes)
        
        attribute_keys = (attributes || {}).keys.map(&:to_s)
        
        if attribute_defaults = self.class.read_inheritable_attribute(:attribute_defaults)
          attribute_defaults.each do |default|
            unless attribute_keys.include?(default.attribute)
              send("#{default.attribute}=", default.value(self))
            end
          end
        end
        
        yield self if block_given?
      end
    end
    
    class Default
      attr_reader :attribute
      
      def initialize(attribute, value)
        @attribute, @value = attribute.to_s, value
      end
      
      def value(record)
        if @value.respond_to?(:call)
          @value.call(record)
        else
          @value
        end
      end
    end
  end
end

class ActiveRecord::Base
  include ActiveRecord::Defaults
end
