# frozen_string_literal: true

require "active_support/core_ext/object/inclusion"

module Categories
  module Matching
    extend ActiveSupport::Concern

    # Find best matching competition race for category. Iterate through traits (weight, equipment, ages, gender, abilities) until there is a
    # single match (or none).
    def best_match_in_event(event)
      debug "Category#best_match_in #{name} in #{event.name}"
      best_match_in event_categories
    end

    # Find best matching competition race for category. Iterate through traits (weight, equipment, ages, gender, abilities) until there is a
    # single match (or none).
    # Some times, a category's results need to be split into multiple categories based on the participant's age
    def best_match_in(event_categories, result_age = nil)
      debug "Category#best_match_in #{name}: #{event_categories.map(&:name).join(', ')}"

      candidate_categories = event_categories.dup

      equivalent_match = candidate_categories.detect { |category| equivalent?(category) }
      debug "equivalent: #{equivalent_match&.name}"
      return equivalent_match if equivalent_match

      # If no weight match, ignore weight and match on age and gender
      if candidate_categories.any? { |category| weight == category.weight }
        candidate_categories = candidate_categories.select { |category| weight == category.weight }
      end
      debug "weight: #{candidate_categories.map(&:name).join(', ')}"
      return candidate_categories.first if one_match?(candidate_categories)
      return nil if candidate_categories.empty?

      candidate_categories = candidate_categories.select { |category| equipment == category.equipment }
      debug "equipment: #{candidate_categories.map(&:name).join(', ')}"
      return candidate_categories.first if one_match?(candidate_categories)
      return nil if candidate_categories.empty?

      candidate_categories = candidate_categories.reject { |category| gender == "M" && category.gender == "F" }
      debug "gender: #{candidate_categories.map(&:name).join(', ')}"
      return candidate_categories.first if one_match?(candidate_categories)
      return nil if candidate_categories.empty?

      if result_age && !senior? && candidate_categories.none? { |category| ages_begin.in?(category.ages) }
        candidate_categories = candidate_categories.select { |category| category.ages.include?(result_age) }
      else
        candidate_categories = candidate_categories.select { |category| ages_begin.in?(category.ages) }
      end
      debug "ages: #{candidate_categories.map(&:name).join(', ')}"
      return candidate_categories.first if one_match?(candidate_categories)
      return nil if candidate_categories.empty?

      unless all_abilities?
        candidate_categories = candidate_categories.select { |category| ability_begin.in?(category.abilities) }
        debug "ability: #{candidate_categories.map(&:name).join(', ')}"
        return candidate_categories.first if one_match?(candidate_categories)
        return nil if candidate_categories.empty?
      end

      # Edge case for unusual age ranges that span juniors and seniors like 15-24
      if !senior? && ages_begin <= Ages::JUNIORS.end && ages_end > Ages::JUNIORS.end
        candidate_categories = candidate_categories.reject(&:junior?)
        debug "overlapping ages: #{candidate_categories.map(&:name).join(', ')}"
        return candidate_categories.first if one_match?(candidate_categories)
        return nil if candidate_categories.empty?
      end

      if junior?
        junior_categories = candidate_categories.select(&:junior?)
        debug "junior: #{junior_categories.map(&:name).join(', ')}"
        return junior_categories.first if junior_categories.one?

        candidate_categories = junior_categories if junior_categories.present?
      end

      if masters?
        masters_categories = candidate_categories.select(&:masters?)
        debug "masters?: #{masters_categories.map(&:name).join(', ')}"
        return masters_categories.first if masters_categories.one?

        candidate_categories = masters_categories if masters_categories.present?
      end

      # FIME. Why is this used? Puts Masters 50+ in Masters 4 over Masters.
      # E.g., if Cat 3 matches Senior Men and Cat 3, use Cat 3
      # Could check size of range and use narrowest if there is a single one more narrow than the others
      # unless candidate_categories.all?(&:all_abilities?)
      #   candidate_categories = candidate_categories.reject(&:all_abilities?)
      # end
      # debug "reject wildcards: #{candidate_categories.map(&:name).join(', ')}"
      # return candidate_categories.first if one_match?(candidate_categories)
      # return nil if candidate_categories.empty?

      # "Highest" is lowest ability number
      # Choose exact ability category begin if women
      # Common edge case where the two highest categories are Pro/1/2 and Women 1/2
      if candidate_categories.one? { |category| category.ability_begin == ability_begin && category.women? && women? }
        ability_category = candidate_categories.detect { |category| category.ability_begin == ability_begin && category.women? && women? }
        debug "ability begin: #{ability_category.name}"
        return ability_category if ability_category.include?(self)
      end

      # Choose highest ability category
      highest_ability = candidate_categories.map(&:ability_begin).min
      if candidate_categories.one? { |category| category.ability_begin == highest_ability }
        highest_ability_category = candidate_categories.detect { |category| category.ability_begin == highest_ability }
        debug "highest ability: #{highest_ability_category.name}"
        return highest_ability_category if highest_ability_category.include?(self)
      end

      # Choose highest ability by gender
      if candidate_categories.one? { |category| category.ability_begin == highest_ability && category.gender == gender }
        highest_ability_category = candidate_categories.detect { |category| category.ability_begin == highest_ability && category.gender == gender }
        debug "highest ability for gender: #{highest_ability_category.name}"
        return highest_ability_category if highest_ability_category.include?(self)
      end

      # Choose highest minimum age if multiple Masters 'and over' categories
      if masters? && candidate_categories.all?(&:and_over?)
        if result_age
          candidate_categories = candidate_categories.reject { |category| category.ages_begin > result_age }
        end
        highest_age = candidate_categories.map(&:ages_begin).max
        highest_age_category = candidate_categories.detect { |category| category.ages_begin == highest_age }
        debug "highest age: #{highest_age_category&.name}"
        return highest_age_category if highest_age_category&.include?(self)
      end

      # Choose narrowest age if multiple Masters categories
      if masters?
        ranges = candidate_categories.select(&:masters?).map do |category|
          category.ages_end - category.ages_begin
        end

        minimum_range = ranges.min
        candidate_categories = candidate_categories.select do |category|
          (category.ages_end - category.ages_begin) == minimum_range
        end

        return candidate_categories.first if one_match?(candidate_categories)
      end

      candidate_categories = candidate_categories.reject { |category| gender == "F" && category.gender == "M" }
      debug "exact gender: #{candidate_categories.map(&:name).join(', ')}"
      return candidate_categories.first if one_match?(candidate_categories)
      return nil if candidate_categories.empty?

      debug "no wild cards: #{candidate_categories.map(&:name).join(', ')}"
      return candidate_categories.first if one_match?(candidate_categories)
      return nil if candidate_categories.empty?

      if candidate_categories.size > 1
        raise "Multiple matches #{candidate_categories.map(&:name)} for #{name}, result age: #{result_age} in #{event_categories.map(&:name).join(', ')}"
      end
    end

    def best_match_by_age_in(event_categories, result_age = nil)
      debug "Category#best_match_by_age_in #{name}, #{result_age}: #{event_categories.map(&:name).join(', ')}"

      candidate_categories = event_categories.dup

      equivalent_match = candidate_categories.detect { |category| equivalent?(category) }
      debug "equivalent: #{equivalent_match&.name}"
      return equivalent_match if equivalent_match

      if result_age && !age_group?
        candidate_categories = candidate_categories.select { |category| category.ages.include?(result_age) }
      else
        candidate_categories = candidate_categories.select { |category| ages_begin.in?(category.ages) }
      end
      debug "ages: #{candidate_categories.map(&:name).join(', ')}"
      return candidate_categories.first if candidate_categories.size == 1

      candidate_categories = candidate_categories.reject { |category| gender == "M" && category.gender == "F" }
      debug "gender: #{candidate_categories.map(&:name).join(', ')}"
      return candidate_categories.first if candidate_categories.size == 1

      # Choose highest minimum age if multiple Masters 'and over' categories
      if masters? && candidate_categories.all?(&:and_over?)
        if result_age
          candidate_categories = candidate_categories.reject { |category| category.ages_begin > result_age }
        end
        highest_age = candidate_categories.map(&:ages_begin).max
        highest_age_category = candidate_categories.select { |category| category.ages_begin == highest_age }
        debug "highest age: #{highest_age_category.map(&:name)}"
        return highest_age_category.first if highest_age_category.one?
      end

      candidate_categories = candidate_categories.reject { |category| gender == "F" && category.gender == "M" }
      debug "exact gender: #{candidate_categories.map(&:name).join(', ')}"

      return candidate_categories.first if candidate_categories.size == 1

      if candidate_categories.size > 1
        raise "Multiple matches #{candidate_categories.map(&:name)} for #{name}, result age: #{result_age} in #{event_categories.map(&:name).join(', ')}"
      end
    end

    def equivalent?(other)
      return false unless other

      abilities == other.abilities &&
        ages == other.ages &&
        equipment == other.equipment &&
        gender == other.gender &&
        weight == other.weight
    end

    # This could be done at the start of best_match_in
    def include?(other, result_age = nil)
      return false unless other

      abilities_include?(other) &&
        ages_include?(other, result_age) &&
        equipment == other.equipment &&
        (men? || other.women?) &&
        (!weight? || weight == other.weight)
    end

    # Some Calculations only have one category, and some categories shoould bever match.
    # E.g., Masters Women and Junior Men
    # Age-matching is more permissive of weight, equipment, etc.
    def one_match?(candidate_categories, result_age = nil)
      return false unless candidate_categories.one?

      candidate_category = candidate_categories.first
      candidate_category.include? self, result_age
    end

    def debug(message)
      if defined?(Rails) && defined?(Rails.logger)
        Rails.logger.debug message
      end
    end
  end
end
