module Test
  module EscapingAssertions
    extend ActiveSupport::Concern
    
    included do
      class_attribute :no_angle_brackets_exceptions
      self.no_angle_brackets_exceptions = []
    end
      
    module ClassMethods
      def assert_no_angle_brackets(*options)
        class_attribute :no_angle_brackets_exceptions
        options = options.extract_options!
        self.no_angle_brackets_exceptions = Array.wrap(options[:except])
      end
    end
  end
end
