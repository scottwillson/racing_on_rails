require_relative "../../test_case"
require_relative "../../../../app/models/categories"
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
        "12/24-Hour 2-Person" => 0..999,
        "A Group" => 0..999,
        "A Group Prime #1" => 0..999,
        "Amateur 19-39 Women" => 3..3,
        "B Group" => 0..999,
        "Beginner Men" => 3..3,
        "Beginner Women" => 3..3,
        "Big Loop 2-Person" => 0..999,
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
        "Category A" => 1..1,
        "Category B" => 2..2,
        "Category C" => 3..3,
        "Category C/Juniors" => 3..3,
        "Clydesdale 200+" => 0..999,
        "Clydesdale" => 0..999,
        "Elite Men" => 0..0,
        "Elite/Category 1 Women" => 0..1,
        "Elite/Category Women" => 0..0,
        "Expert (Category 1) Men 45+" => 1..1,
        "Junior Men 15-16" => 0..999,
        "Junior Men" => 0..999,
        "Junior Women" => 0..999,
        "Junior Men - 2K" => 0..999,
        "Masters Men" => 0..999,
        "Masters Men 1/2/3" => 1..3,
        "Masters Men 4/5 50+" => 4..5,
        "Masters Men 4/5" => 4..5,
        "Masters Men 50+ 4/5" => 4..5,
        "Masters Men 50+" => 0..999,
        "Masters Men 50-50/60+" => 0..999,
        "Masters Women 35+ A" => 1..1,
        "Masters Women 30-34/500m" => 0..999,
        "Masters Women 30-39/40-49/50+" => 0..999,
        "Men 3" => 3..3,
        "Men 3/4" => 3..4,
        "Men Category 3-5 (120-Mile)" => 3..5,
        "Men U18" => 0..999,
        "Novice Men A" => 4..4,
        "Novice Men B" => 4..4,
        "Party of 2" => 0..999,
        "Party of 9" => 0..999,
        "Race 1" => 0..999,
        "Race 2" => 0..999,
        "Senior Men 1/2/3 Sprint" => 1..3,
        "Senior Men Pro/1/2" => 0..2,
        "Senior Men" => 0..999,
        "Senior Women" => 0..999,
        "Singlespeed" => 0..999,
        "Sprint A" => 0..999,
        "Sprint B" => 0..999,
        "Sprint C" => 0..999,
        "Sprint D" => 0..999,
        "Sprint E" => 0..999,
        "Women 1/2/3" => 1..3,
        "Women 1/2/3 Sprint" => 1..3,
        "Women 1-3" => 1..3,
        "Women 4/5" => 4..5,
        "Women A" => 1..1,
      }.each do |name, ability|
        category = Stub.new
        category.name = name
        assert_equal ability, category.ability_range_from_name, name
      end
    end
  end
end
