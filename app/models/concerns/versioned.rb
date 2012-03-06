module Concerns
  module Versioned
    extend ActiveSupport::Concern
    
    included do
      versioned :initial_version => true
      before_save :set_updater
    end

    module InstanceMethods
      def created_by
        versions.first.try :user
      end

      def updated_by
        versions.last.try :user
      end

      def set_updater
        @updater ||= Person.current
        true
      end

      def created_from_result?
        !created_by.nil? && created_by.kind_of?(::Event)
      end
      
      def updated_after_created?
        created_at && updated_at && ((updated_at - created_at) > 1.hour)
      end
    end
  end
end
