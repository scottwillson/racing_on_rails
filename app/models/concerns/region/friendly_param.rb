module Concerns
  module Region
    module FriendlyParam
      extend ActiveSupport::Concern

      def to_param
        if name
          name.downcase.gsub(/\W/, " ").strip.gsub(/  +/, " ").gsub(" ", "-")
        end
      end
    end
  end
end
