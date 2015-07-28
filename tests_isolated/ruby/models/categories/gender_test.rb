require_relative "../../test_case"
require_relative "../../../../app/models/categories/gender"

module Categories
  # :stopdoc:
  class GenderTest < Ruby::TestCase
    class Stub
      def self.before_save(symbol); end
      include Gender
      attr_accessor :gender, :name
    end

    def test_set_gender_from_name
      {
        "Senior Men" => "M",
        "Senior Women" => "F",
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
        "Clydesdale" => "M",
        "Elite Men" => "M",
        "Elite/Category Women" => "F",
        "Singlespeed" => "M"
      }.each do |name, gender|
        category = Stub.new
        category.name = name
        category.set_gender_from_name
        assert_equal gender, category.gender, name
      end
    end
  end
end
