require_relative "../../test_case"
require_relative "../../../../app/models/categories/ages"

module Categories
  # :stopdoc:
  class AgesTest < Ruby::TestCase
    class Stub
      def self.before_save(symbol); end
      include Ages
      attr_accessor :ages_begin, :ages_end, :name
    end

    def test_ages
      stub = Stub.new
      stub.ages = 12..15
      assert_equal 12, stub.ages_begin, "ages_begin"
      assert_equal 15, stub.ages_end, "ages_end"
      assert_equal 12..15, stub.ages, "Default age range"
    end

    def test_set_ages_as_string
      stub = Stub.new
      stub.ages = "12-15"
      assert_equal 12, stub.ages_begin, "ages_begin"
      assert_equal 15, stub.ages_end, "ages_end"
      assert_equal 12..15, stub.ages, "Default age range"
    end

    def test_add_ages_from_name
      category = Stub.new
      assert_equal 60..999, category.ages_from_name("Masters Men 60+")
      assert_equal 50..59, category.ages_from_name("Masters Men 50-59")
      assert_equal 10..18, category.ages_from_name("Women Junior")
      assert_equal 30..999, category.ages_from_name("Master Men")
    end

    def test_age_group
      category = Stub.new
      assert !category.age_group?, "No ages age_group?"

      category = Stub.new
      category.ages_begin = 0
      category.ages_end = 999
      assert !category.age_group?, "0..99 age_group?"

      category = Stub.new
      category.ages_begin = 60
      category.ages_end = 999
      assert category.age_group?, "60..99 age_group?"

      category = Stub.new
      category.ages_begin = 10
      category.ages_end = 18
      assert category.age_group?, "10..18 age_group?"
    end
  end
end
