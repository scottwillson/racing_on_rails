# frozen_string_literal: true

module Categories
  module Weight
    extend ActiveSupport::Concern

    def set_weight_from_name
      self.weight = weight_from_name
    end

    # Relies on normalized name
    def weight_from_name
      name[/Athena|Clydesdale/]
    end
  end
end
