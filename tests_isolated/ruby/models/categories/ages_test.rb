# frozen_string_literal: true

require_relative "../../test_case"
require_relative "../../../../app/models/categories"
require_relative "../../../../app/models/categories/ages"

module Categories
  # :stopdoc:
  class AgesTest < Ruby::TestCase
    class Stub
      def self.before_save(_); end
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
      assert_equal 9..18, category.ages_from_name("Women Junior")
      assert_equal 30..999, category.ages_from_name("Master Men")
      assert_equal 0..34, category.ages_from_name("Category 2 Men U35")
      assert_equal 15..18, category.ages_from_name("Junior 15+")
      assert_equal 9..18, category.ages_from_name("Men 9-18")
      assert_equal 9..9, category.ages_from_name("Junior Men 9")
      assert_equal 9..18, category.ages_from_name("Junior Men 3/4/5")
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

    def test_junior
      category = Stub.new
      assert !category.junior?, "No ages junior?"

      category = Stub.new
      category.ages_begin = 0
      category.ages_end = 999
      assert !category.junior?, "0..99 junior?"

      category = Stub.new
      category.ages_begin = 60
      category.ages_end = 999
      assert !category.junior?, "60..99 junior?"

      category = Stub.new
      category.ages_begin = 10
      category.ages_end = 18
      assert category.junior?, "10..18 junior?"

      category = Stub.new
      category.ages_begin = 15
      category.ages_end = 16
      assert category.junior?, "15..16 junior?"

      category = Stub.new
      category.ages_begin = 30
      category.ages_end = 99
      assert !category.junior?, "30..99 junior?"
    end

    def test_team
      category = Stub.new
      assert_equal 40..49, category.ages_from_name("Men 160-199")
      assert_equal 50..59, category.ages_from_name("Men 200-239")
      assert_equal 60..999, category.ages_from_name("Men 240+")
      assert_equal 40..49, category.ages_from_name("Women 160-199")
      assert_equal 50..59, category.ages_from_name("Women 200-239")
      assert_equal 60..999, category.ages_from_name("Women 240+")
      assert_equal 50..999, category.ages_from_name("Two-Person Masters 100+")
    end
  end
end
