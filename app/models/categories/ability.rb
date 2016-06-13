module Categories
  module Ability
    extend ActiveSupport::Concern

    included do
      before_save :set_ability_range_from_name
    end

    def set_ability_range_from_name
      self.ability_begin = ability_from_name
      self.ability_end = end_ability_from_name
    end

    def ability_from_name
      single_ability_string = name[/ \d /] || name[/ (\d)\)/, 1] || name[/ (\d)\Z/, 1]
      if single_ability_string
        single_ability_string.to_i
      elsif name[%r{\d/\d}] && name[%r{(\d)/(\d)}, 1].to_i > 0
        name[%r{(\d)/(\d)}, 1].to_i
      else
        0
      end
    end

    def end_ability_from_name
      if name[%r{\d/\d}] && name[%r{(\d/)+(\d)}, 2].to_i > 0
        name[%r{(\d/)+(\d)}, 2].to_i
      elsif ability_from_name > 0
        ability_from_name
      else
        ::Categories::MAXIMUM
      end
    end

    def ability_range_from_name
      ability_from_name..end_ability_from_name
    end

    def ability
      ability_begin
    end

    def ability=(value)
      self.ability_begin = value
    end

    def ability_range
      ability_begin..ability_end
    end
  end
end
