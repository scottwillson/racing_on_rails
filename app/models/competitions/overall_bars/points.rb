module Competitions
  module OverallBars
    module Points
      extend ActiveSupport::Concern

      def points_for(scoring_result)
        301 - scoring_result.numeric_place
      end
    end
  end
end
