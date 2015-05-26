module Categories
  module Gender
    extend ActiveSupport::Concern

    included do
      before_save :set_gender_from_name
    end

    # Relies on normalized name
    def set_gender_from_name
      if name[/women/i]
        self.gender = "F"
      else
        self.gender = "M"
      end
    end
  end
end
