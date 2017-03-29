require_relative "../../test_case"
require_relative "../../../../app/models/categories/weight"

module Categories
  # :stopdoc:
  class WeightTest < Ruby::TestCase
    class Stub
      def self.before_save(_); end
      include Weight
      attr_accessor :name
    end

    def test_set_gender_from_name
      category = Stub.new

      category.name = "Beginner Men"
      assert_nil category.weight_from_name, "Beginner Men"

      category.name = "Clydesdale"
      assert_equal "Clydesdale", category.weight_from_name, "Clydesdale"

      category.name = "Athena"
      assert_equal "Athena", category.weight_from_name, "Athena"
    end
  end
end
