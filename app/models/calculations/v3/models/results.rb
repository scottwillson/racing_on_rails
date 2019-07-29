# frozen_string_literal: true

module Calculations
  module V3
    module Models
      module Results
        def not_rejected?
          !rejected?
        end

        # Opposite convention of ::Result (for now)
        def numeric_place
          case place&.to_i
          when nil, 0
            Float::INFINITY
          else
            place.to_i
          end
        end

        def placed?
          numeric_place != Float::INFINITY
        end

        def points?
          points&.positive?
        end

        def reject(reason)
          raise(ArgumentError, "already rejected because #{rejection_reason}") if rejected?

          @rejection_reason = reason
          @rejected = true
          @points = 0
        end

        def rejected?
          @rejected
        end
      end
    end
  end
end
