require "test_helper"

module Categories
  # :stopdoc:
  class NameTest < ActiveSupport::TestCase
    test "name should be normalized when set" do
      assert_equal "Senior Men", Category.new(name: "SENIOR MEN").name, "Senior Men"
      assert_equal "Senior Men", Category.new(name: " Senior Men ").name, "' Senior Men '"
      assert_equal "Senior Men", Category.new(name: "     Senior Men").name, "'     Senior Men'"
      assert_equal "Senior Men", Category.new(name: "Senior    Men").name, "'Senior    Men'"
      assert_equal "Senior Men", Category.new(name: "Senior	Men").name, "'Senior	Men'"
    end

    test "find_or_create_by_normalized_name" do
      category = FactoryGirl.create(:category, name: "Senior Men")
      assert_equal category, Category.find_or_create_by_normalized_name(" Senior   Men  ")
    end

    test "cleanup_case should set proper case" do
      assert_equal "Senior Men", Category.cleanup_case("SENIOR MEN"), "SENIOR MEN"
      assert_equal "Senior Men", Category.cleanup_case("senior men"), "senior men"
      assert_equal "Sport Women 40 & Over", Category.cleanup_case("SPORT WOMEN 40 & OVER"), "SPORT WOMEN 40 & OVER"
      assert_equal "Jr 16-18", Category.cleanup_case("JR 16-18"), "JR 16-18"
      assert_equal "CBRA", Category.cleanup_case("CBRA"), "CBRA"
      assert_equal "MTB", Category.cleanup_case("MTB"), "MTB"
      assert_equal "SS", Category.cleanup_case("SS"), "SS"
      assert_equal "Demonstration - 500 M TT", Category.cleanup_case("Demonstration - 500 m TT"), "Demonstration - 500 m TT"
      assert_equal "Pro/SemiPro", Category.cleanup_case("Pro/SemiPro"), "Pro/SemiPro"
      assert_equal "Cat C/Beginner Men", Category.cleanup_case("Cat C/beginner Men"), "Cat C/beginner Men"
      assert_equal "(Beginner) Cat 3 Men 13 & Under", Category.cleanup_case("(beginner) Cat 3 Men 13 & Under"), "(beginner) Cat 3 Men 13 & Under"
      assert_equal "Cat II 55+", Category.cleanup_case("Cat Ii 55+"), "Cat Ii 55+"
      assert_equal "Category 5A", Category.cleanup_case("Category 5a"), "Category 5a"
      assert_equal "Category 5A", Category.cleanup_case("Category 5A"), "Category 5A"
      assert_equal "Team of 4 - 40+", Category.cleanup_case("TEAM OF 4 - 40+"), "TEAM OF 4 - 40+"
      assert_equal "TTT", Category.cleanup_case("TTT"), "TTT"
      # Nothing is perfect
      assert_equal "Tt-tandem", Category.cleanup_case("Tt-tandem"), "Tt-tandem"
    end
  end
end
