require_relative "../../test_case"
require_relative "../../../../app/models/categories/ability"

module Categories
  # :stopdoc:
  class AbilityTest < Ruby::TestCase
    class Stub
      def self.before_save(symbol); end
      include Ability
      attr_accessor :ability, :name
    end

    def test_set_ability_from_name
      {
        "Senior Men" => 0,
        "Senior Women" => 0,
        "Category 1 Men 19-34" => 1,
        "Category 1 Men 35-44" => 1,
        "Category 1 Men 45+" => 1,
        "Category 2 Men 35-44" => 2,
        "Category 2 Men 45-54" => 2,
        "Category 2 Men 55+" => 2,
        "Category 2 Men U35" => 2,
        "Category 2 Women 35-44" => 2,
        "Category 2 Women 45+" => 2,
        "Category 2 Women U35" => 2,
        "Category 3 Men 10-14" => 3,
        "Category 3 Men 15-18" => 3,
        "Category 3 Men 19-44" => 3,
        "Category 3 Men 45+" => 3,
        "Category 3 Women 10-14" => 3,
        "Category 3 Women 15-18" => 3,
        "Category 3 Women 19+" => 3,
        "Clydesdale" => 0,
        "Elite Men" => 0,
        "Elite/Category Women" => 0,
        "Singlespeed" => 0
      }.each do |name, ability|
        category = Stub.new
        category.name = name
        category.set_ability_from_name
        assert_equal ability, category.ability, name
      end
    end
  end
end
