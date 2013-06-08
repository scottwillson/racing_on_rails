module Concerns
  module Event
    module Names
      extend ActiveSupport::Concern

      module ClassMethods
        def friendly_class_name
          name.underscore.humanize.titleize
        end
      end
      
      def default_name
        "Untitled"
      end
  
      # Parent's name. Own name if no parent
      def parent_event_name
        parent.try(:name) || name
      end
  
      def name_with_date
        "#{name} (#{short_date})"
      end

      def full_name_with_date
        "#{full_name} (#{short_date.try :strip})"
      end

      # Try to intelligently combined parent name and child name for schedule pages
      def full_name
        if parent.nil?
          name
        elsif parent.full_name == name
          name
        elsif name[ parent.full_name ]
          name
        else
          "#{parent.full_name}: #{name}"
        end
      end
  
      def friendly_class_name
        self.class.friendly_class_name
      end
    end
  end
end
