# frozen_string_literal: true

module Categories
  module Equipment
    extend ActiveSupport::Concern

    def set_equipment_from_name
      self.equipment = equipment_from_name
    end

    # Relies on normalized name
    def equipment_from_name
      # Technically different but always grouped together for BAR, etc.
      if name[/Singlespeed/] || name[/Fix/]
        "Singlespeed/Fixed"
      else
        name[/Eddy|Fat Bike|Hardtail|Merckx|Stampede|Tandem|Unicycle/]
      end
    end

    def equipment?
      equipment.present?
    end
  end
end
