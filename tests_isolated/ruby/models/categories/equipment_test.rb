# frozen_string_literal: true

require_relative "../../test_case"
require_relative "../../../../app/models/categories/equipment"

module Categories
  # :stopdoc:
  class EquipmentTest < Ruby::TestCase
    class Stub
      def self.before_save(_); end
      include Equipment
      attr_accessor :name
    end

    def test_set_equipment_from_name
      {
        "Beginner Men" => nil,
        "Clydesdale" => nil,
        "Athena" => nil,
        "Tandem" => "Tandem",
        "Eddy" => "Eddy",
        "Fat Bike" => "Fat Bike",
        "Merckx" => "Merckx",
        "Singlespeed" => "Singlespeed",
        "Singlespeed/Fixed" => "Singlespeed",
        "Stampede" => "Stampede",
        "Unicycle" => "Unicycle"
      }.each do |name, equipment|
        category = Stub.new
        category.name = name

        # Grr.
        if equipment
          assert_equal equipment, category.equipment_from_name, name
        else
          assert_nil category.equipment_from_name, name
        end
      end
    end
  end
end
