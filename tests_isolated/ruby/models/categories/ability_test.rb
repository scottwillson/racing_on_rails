require_relative "../../test_case"
require_relative "../../../../app/models/categories/ability"

module Categories
  # :stopdoc:
  class AbilityTest < Ruby::TestCase
    class Stub
      def self.before_save(symbol); end
      include Ability
      attr_accessor :name
    end

    def test_ability_range_from_name
      {
        "Beginner Men" => 0..999,
        "Beginner Women" => 0..999,
        "Category 1 Men 19-34" => 1..1,
        "Category 1 Men 35-44" => 1..1,
        "Category 1 Men 45+" => 1..1,
        "Category 2 Men 35-44" => 2..2,
        "Category 2 Men 45-54" => 2..2,
        "Category 2 Men 55+" => 2..2,
        "Category 2 Men U35" => 2..2,
        "Category 2 Women 35-44" => 2..2,
        "Category 2 Women 45+" => 2..2,
        "Category 2 Women U35" => 2..2,
        "Category 3 Men 10-14" => 3..3,
        "Category 3 Men 15-18" => 3..3,
        "Category 3 Men 19-44" => 3..3,
        "Category 3 Men 45+" => 3..3,
        "Category 3 Women 10-14" => 3..3,
        "Category 3 Women 15-18" => 3..3,
        "Category 3 Women 19+" => 3..3,
        "Category A" => 0..999,
        "Category B" => 0..999,
        "Category C" => 0..999,
        "Category C/Juniors" => 0..999,
        "Clydesdale 200+" => 0..999,
        "Clydesdale" => 0..999,
        "Elite Men" => 0..999,
        "Elite/Category 1 Women" => 1..1,
        "Elite/Category Women" => 0..999,
        "Expert (Category 1) Men 45+" => 1..1,
        "Junior Men 15-16" => 0..999,
        "Junior Men" => 0..999,
        "Junior Women" => 0..999,
        "Masters Men" => 0..999,
        "Masters Men 1/2/3" => 1..3,
        "Masters Men 4/5 50+" => 4..5,
        "Masters Men 4/5" => 4..5,
        "Masters Men 50+ 4/5" => 4..5,
        "Masters Men 50+" => 0..999,
        "Masters Women 35+ A" => 0..999,
        "Men 3" => 3..3,
        "Men 3/4" => 3..4,
        "Men U18" => 0..999,
        "Senior Men Pro/1/2" => 1..2,
        "Senior Men" => 0..999,
        "Senior Women" => 0..999,
        "Singlespeed" => 0..999,
        "Women 1/2/3" => 1..3,
        "Women 4/5" => 4..5,
        "Women A" => 0..999,
      }.each do |name, ability|
        category = Stub.new
        category.name = name
        assert_equal ability, category.ability_range_from_name, name
      end
    end
  end
end
