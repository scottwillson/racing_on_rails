require_relative "../../test_case"
require_relative "../../../../app/models/categories/weight"

module Categories
  # :stopdoc:
  class WeightTest < Ruby::TestCase
    class Stub
      def self.before_save(symbol); end
      include Weight
      attr_accessor :name
    end

    def test_set_gender_from_name
      {
        "Beginner Men" => nil,
        "Clydesdale" => "Clydesdale",
        "Athena" => "Athena",
      }.each do |name, weight|
        category = Stub.new
        category.name = name
        assert_equal weight, category.weight_from_name, name
      end
    end
  end
end
