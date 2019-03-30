# frozen_string_literal: true

# Canonical category with name, ability, age, etc. Not associated with an individual event.
# EventCategory joins a Category with an event.
module Calculations
  module V3
    module Models
      class Category
        include ::Categories::Ability
        include ::Categories::Ages
        include ::Categories::Equipment
        include ::Categories::Gender
        include ::Categories::Matching
        include ::Categories::Weight

        attr_accessor :ability_begin
        attr_accessor :ability_end
        attr_accessor :ages_begin
        attr_accessor :ages_end
        attr_accessor :equipment
        attr_accessor :gender
        attr_reader :name
        attr_accessor :weight

        @@logger = nil

        def initialize(name)
          @name = name

          @ability_begin = 0
          @ability_end = 999
          @ages_begin = 0
          @ages_end = 999
          @gender = "M"

          set_abilities_from_name
          set_ages_from_name
          set_equipment_from_name
          set_gender_from_name
          set_weight_from_name
        end

        def logger
          @@logger
        end

        def ==(other)
          return false if other.nil?

          other.name == name
        end

        def eql?(other)
          self == other
        end

        def hash
          name&.hash
        end
      end
    end
  end
end
