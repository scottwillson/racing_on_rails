require_relative "../../test_case"
require_relative "../../../../app/models/categories/equipment"

module Categories
  # :stopdoc:
  class EquipmentTest < Ruby::TestCase
    class Stub
      def self.before_save(symbol); end
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
        "Singlespeed" => "Singlespeed",
        "Singlespeed/Fixed" => "Singlespeed",
        "Unicycle" => "Unicycle",
      }.each do |name, equipment|
        category = Stub.new
        category.name = name
        assert_equal equipment, category.equipment_from_name, name
      end
    end
  end
end
