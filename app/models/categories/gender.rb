# frozen_string_literal: true

module Categories
  module Gender
    extend ActiveSupport::Concern

    def set_gender_from_name
      self.gender = gender_from_name
    end

    # Relies on normalized name
    def gender_from_name
      if name[/women|athena|girl/i]
        "F"
      else
        "M"
      end
    end

    def men?
      gender == "M"
    end

    def non_binary?
      gender == "NB"
    end

    def women?
      gender == "F"
    end
  end
end
