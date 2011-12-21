module Concerns
  module OverallBar
    module Points
      extend ActiveSupport::Concern

      def points_for(scoring_result)
        301 - scoring_result.place.to_i
      end
    end
  end
end
