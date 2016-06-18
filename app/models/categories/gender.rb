module Categories
  module Gender
    extend ActiveSupport::Concern

    included do
      before_save :set_gender_from_name
    end

    def set_gender_from_name
      self.gender = gender_from_name
    end

    # Relies on normalized name
    def gender_from_name
      if name[/women|athena/i]
        "F"
      else
        "M"
      end
    end
  end
end
