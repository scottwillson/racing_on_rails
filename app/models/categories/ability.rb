module Categories
  module Ability
    extend ActiveSupport::Concern

    NAME_ABILITIES = {
      "Pro" => 0,
      "Semi-Pro" => 0,
      "Elite" => 0,
      "A" => 1,
      "Expert" => 1,
      "B" => 2,
      "Sport" => 2,
      "C" => 3,
      "Amateur" => 3,
      "Beginner" => 3,
      "Novice" => 4,
    }.freeze

    included do
      before_save :set_ability_range_from_name
    end

    # Pro/1/2 => 0..2
    def set_ability_range_from_name
      ability_range = ability_range_from_name
      self.ability_begin = ability_range.first
      self.ability_end = ability_range.last
      ability_range
    end

    # Simply Women 3 or Men A?
    def single_ability(name_token)
      single_ability_string = name_token[/ \d /] || name_token[/ (\d)\)/, 1] || name_token[/ (\d)\Z/, 1]
      if single_ability_string
        single_ability_string.to_i
      elsif name_token[%r{\d[/-]\d}] && name_token[%r{(\d)[/-](\d)}, 1].to_i > 0
        name_token[%r{(\d)[/-](\d)}, 1].to_i
      end
    end

    # 0 in Pro/1/2
    def ability_from_name(name_token)
      values = values_from_names(name_token)
      values.min || 0
    end

    # 2 in Pro/1/2
    def end_ability_from_name(name_token)
      values = values_from_names(name_token)

      if abilities_joined_by_slashes_or_dashes?(name_token)
        values << last_ability_joined_by_slash_or_dash(name_token)
      elsif ability_from_name(name_token) > 0
        values << ability_from_name(name_token)
      end

      values.max || Categories::MAXIMUM
    end

    # Pro/1/2 => [ 0, 1, 2 ]
    def values_from_names(name_token)
      values = NAME_ABILITIES.select do |ability_name, value|
        name_token[/\b#{ability_name}\b/]
      end.values
      values << single_ability(name_token) if single_ability(name_token)
      values
    end

    # 1/3 or 1-3
    def abilities_joined_by_slashes_or_dashes?(name_token)
      name_token[%r{\d[/-]\d}] && last_ability_joined_by_slash_or_dash(name_token) > 0
    end

    def last_ability_joined_by_slash_or_dash(name_token)
      name_token[%r{(\d[/-])+(\d)}, 2].to_i
    end

    # Ignore tokens like A Group or Race 2 that include category tokens
    def strip_descriptive_tokens
      name
        .gsub(%r{Race \d+}, "")
        .gsub(%r{Party of \d+}, "")
        .gsub(%r{Novice Men \w}, "Novice")
        .gsub(%r{\d\d+[/-]\d\d+}, "")
        .gsub(/\w group/i, "")
        .gsub(/\d-person/i, "")
        .gsub(/\d+-hour/i, "")
        .gsub(/sprint[ -]+\w/i, "")
        .gsub(/sprint/i, "")
    end

    # Pro/1/2 => 0..2
    def ability_range_from_name
      name_token = strip_descriptive_tokens
      ability_from_name(name_token)..end_ability_from_name(name_token)
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
