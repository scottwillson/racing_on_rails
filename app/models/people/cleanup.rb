module People
  module Cleanup
    extend ActiveSupport::Concern

    included do
      before_validation :cleanup
    end

    # Fix common formatting mistakes and inconsistencies
    def cleanup
      cleanup_name
    end

    def cleanup_name
      if first_name.present?
        self.first_name = first_name.strip
      end

      if last_name.present?
        self.last_name = last_name.strip
      end
    end
  end
end
