module Categories
  module Ability
    extend ActiveSupport::Concern

    included do
      before_save :set_ability_from_name
    end

    # Naive. Only works correctly for categories like "Category 2 Men".
    # Does not handle categories like "Women 1/2/3" and many others.
    def set_ability_from_name
      ability_string = name[/ \d /]
      if ability_string
        self.ability = ability_string.to_i
      else
        self.ability = 0
      end
    end
  end
end
