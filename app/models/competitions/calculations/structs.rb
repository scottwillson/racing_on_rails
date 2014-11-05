module Competitions
  module Calculations
    module Structs
      # Use simple datatypes with no behavior. Hash doesn't have method-like accessors, which means we
      # can't use symbol to proc. E.g., results.sort_by(&:points). OpenStruct is slow. Full-blown classes
      # are overkill. Could add methods to Struct using do…end, ActiveModels or maybe subclass Hash but Struct
      # works well.
      #
      # Struct::Result would clash with Active Record models so Structs are prefixed with "Calculator."
      # Source result or calculated competition result.
      # +tied+ is plumbing set during calculation. If place method can't break a tie, results are marked as "tied" so they
      # are given the same points.
      #
      # +team_size+ is calculated here, too, though it could be passed in.
      Struct.new(
        "CalculatorResult",
        :bar, 
        :category_id, 
        :category_name,
        :date, 
        :date_of_birth, 
        :event_id, 
        :field_size, 
        :id, 
        :ironman,
        :member_from, 
        :member_to, 
        :multiplier, 
        :participant_id, 
        :place, 
        :points, 
        :race_id, 
        :sanctioned_by, 
        :scores,
        :team_member, 
        :team_name,
        :team_size, 
        :tied, 
        :type, 
        :year
      )

      # Ties a source result to a competition result.
      # CalculatorScore#numeric_place is source result's place.
      Struct.new("CalculatorScore", :date, :numeric_place, :participant_id, :points, :source_result_id, :team_size)

      # Create new copy of a Struct with +attributes+
      def merge_struct(struct, attributes)
        new_struct = struct.dup
        attributes.each do |k, v|
          new_struct[k] = v
        end
        new_struct
      end
    end
  end
end
