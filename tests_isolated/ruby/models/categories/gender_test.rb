require_relative "../../test_case"
require_relative "../../../../app/models/categories/gender"

module Categories
  # :stopdoc:
  class GenderTest < Ruby::TestCase
    class Stub
      def self.before_save(symbol); end
      include Gender
      attr_accessor :name
    end

    def test_set_gender_from_name
      {
        "Beginner Men" => "M",
        "Beginner Women" => "F",
        "Category 1 Men 19-34" => "M",
        "Category 1 Men 35-44" => "M",
        "Category 1 Men 45+" => "M",
        "Category 2 Men 35-44" => "M",
        "Category 2 Men 45-54" => "M",
        "Category 2 Men 55+" => "M",
        "Category 2 Men U35" => "M",
        "Category 2 Women 35-44" => "F",
        "Category 2 Women 45+" => "F",
        "Category 2 Women U35" => "F",
        "Category 3 Men 10-14" => "M",
        "Category 3 Men 15-18" => "M",
        "Category 3 Men 19-44" => "M",
        "Category 3 Men 45+" => "M",
        "Category 3 Women 10-14" => "F",
        "Category 3 Women 15-18" => "F",
        "Category 3 Women 19+" => "F",
        "Category A" => "M",
        "Category B" => "M",
        "Category C" => "M",
        "Category C/Juniors" => "M",
        "Category Pro/1/2 Men" => "M",
        "Clydesdale 200+" => "M",
        "Clydesdale" => "M",
        "Elite Men" => "M",
        "Elite/Category 1 Women" => "F",
        "Elite/Category Women" => "F",
        "Expert (Category 1) Men 45+" => "M",
        "Junior Men 15-16" => "M",
        "Junior Men" => "M",
        "Junior Women" =>  "F",
        "Masters Men 1/2/3" => "M",
        "Masters Men 4/5" => "M",
        "Masters Men 50+" => "M",
        "Masters Women 35+ A" => "F",
        "Men U18" => "M",
        "Senior Men Pro/1/2" => "M",
        "Senior Men" => "M",
        "Senior Women" => "F",
        "Singlespeed" => "M",
        "Women 1/2" => "F",
        "Women 1/2/3" => "F",
        "Women 4/5" => "F",
        "Women A" => "F"
      }.each do |name, gender|
        category = Stub.new
        category.name = name
        assert_equal gender, category.gender_from_name, name
      end
    end
  end
end
