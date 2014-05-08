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
      assert_equal "Category 3 Men", Category.new(name: "cat 3 Men").name, "cat 3 Men"
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
      assert_equal "TT-tandem", Category.cleanup_case("Tt-tandem"), "Tt-tandem"
      assert_equal "Junior TT-tandem", Category.cleanup_case("Junior Tt-tandem"), "Junior Tt-tandem"
      assert_equal "Attendee", Category.cleanup_case("Attendee"), "Attendee"
      assert_equal "CCX", Category.cleanup_case("Ccx"), "Ccx"
      assert_equal "CX", Category.cleanup_case("Cx"), "Cx"
    end

    test "strip_whitespace" do
      assert_equal "Men 30-39", Category.strip_whitespace("Men 30 - 39"), "Men 30 - 39"
      assert_equal "Men 30-39", Category.strip_whitespace("Men 30- 39"), "Men 30- 39"
      assert_equal "Men 30-39", Category.strip_whitespace("Men 30 -39"), "Men 30 -39"

      assert_equal "Men 30+", Category.strip_whitespace("Men 30+"), "Men 30+"
      assert_equal "Men 30+", Category.strip_whitespace("Men30+"), "Men30+"
      assert_equal "Men 30+", Category.strip_whitespace("Men 30 +"), "Men 30 +"

      assert_equal "Women 30+", Category.strip_whitespace("Women30+"), "Women30+"

      assert_equal "U14", Category.strip_whitespace("U 14"), "U 14"
      assert_equal "U14", Category.strip_whitespace("U-14"), "U-14"

      assert_equal "Pro 1/2", Category.strip_whitespace("Pro 1 / 2"), "Pro 1 / 2"
      assert_equal "Pro 1/2", Category.strip_whitespace("Pro 1/ 2"), "Pro 1/ 2"
      assert_equal "Pro 1/2", Category.strip_whitespace("Pro 1 /2"), "Pro 1 /2"
      assert_equal "Pro/Expert Women", Category.strip_whitespace("Pro / Expert Women"), "Pro / Expert Women"

      assert_equal "6 - race", Category.strip_whitespace("6- race"), "6 - race"
    end

    test "#cleanup_punctuation" do
      assert_equal "Category 1/2", Category.cleanup_punctuation("Category 1/2/"), "Category 1/2/"
      assert_equal "Category 1/2", Category.cleanup_punctuation("Category 1/2:"), "Category 1/2:"
      assert_equal "Category 1/2", Category.cleanup_punctuation("Category 1/2."), "Category 1/2."

      assert_equal "Category 4/5 Junior", Category.cleanup_punctuation("Category 4/5 (Junior)"), "Category 4/5 (Junior)"
      assert_equal "Category 4/5 Men", Category.cleanup_punctuation("Category 4/5 (Men)"), "Category 4/5 (Men)"

      assert_equal "Category 4/5", Category.cleanup_punctuation("Category 4//5"), "Category 4//5"
    end

    test "#expand_abbreviations" do
      assert_equal "senior men", Category.expand_abbreviations("senior men"), "senior men"
      assert_equal "Category 3", Category.expand_abbreviations("Cat 3"), "Cat 3"
      assert_equal "Category 3", Category.expand_abbreviations("cat 3"), "cat 3"
      assert_equal "Category 3", Category.expand_abbreviations("Category 3"), "Category 3"
      assert_equal "Category 5", Category.expand_abbreviations("Cat. 5"), "Cat. 5"
      assert_equal "Women (All Categories)", Category.expand_abbreviations("Women (All Categories)"), "Women (All Categories)"
      assert_equal "Category 3", Category.expand_abbreviations("cat3"), "cat3"
      assert_equal "Category 1 Men 40+", Category.expand_abbreviations("Category 1MEN 40+"), "Category 1MEN 40+"
      assert_equal "Category 4 Men", Category.expand_abbreviations("Category 4/ Men"), "Category 4/ Men"

      assert_equal "1/2", Category.expand_abbreviations("1,2"), "1,2"
      assert_equal "1/2", Category.expand_abbreviations("1-2"), "1-2"
      assert_equal "1/2/3", Category.expand_abbreviations("1,2,3"), "1,2,3"
      assert_equal "1/2/3", Category.expand_abbreviations("1-2-3"), "1-2-3"
      assert_equal "3/4/5", Category.expand_abbreviations("3.4.5"), "3.4.5"

      assert_equal "Junior 10-12", Category.expand_abbreviations("Jr 10-12"), "Jr 10-12"
      assert_equal "Junior 10-12", Category.expand_abbreviations("Jr. 10-12"), "Jr. 10-12"
      assert_equal "Junior 10-12", Category.expand_abbreviations("Junior 10-12"), "Junior 10-12"
      assert_equal "Junior 10-12", Category.expand_abbreviations("Juniors 10-12"), "Juniors 10-12"

      assert_equal "Junior Women 13-14", Category.expand_abbreviations("Jr Wm 13-14"), "Jr Wm 13-14"
      assert_equal "Junior Women 13-14", Category.expand_abbreviations("Jr Wmen 13-14"), "Jr Wmen 13-14"
      assert_equal "Junior Women 13-14", Category.expand_abbreviations("Jr Wmn 13-14"), "Jr Wmn 13-14"
      assert_equal "Junior Women 13-14", Category.expand_abbreviations("Jr Wom 13-14"), "Jr Wom 13-14"
      assert_equal "Junior Women 13-14", Category.expand_abbreviations("Jr Women 13-14"), "Jr Women 13-14"
      assert_equal "Category 3 Women 35+", Category.expand_abbreviations("Cat 3 W 35+"), "Cat 3 W 35+"

      assert_equal "Men Keirin", Category.expand_abbreviations("Men's Keirin"), "Men's Keirin"
      assert_equal "Men Keirin", Category.expand_abbreviations("Mens Keirin"), "Mens Keirin"
      assert_equal "Women Keirin", Category.expand_abbreviations("Women's Keirin"), "Men's Keirin"
      assert_equal "Women Keirin", Category.expand_abbreviations("Womens Keirin"), "Mens Keirin"
      assert_equal "50+ Sport Men", Category.expand_abbreviations("50+ Sport Male"), "50+ Sport Male"
      assert_equal "Beginner 19+ Women", Category.expand_abbreviations("Beginner 19+ Female"), "Beginner 19+ Female"
      assert_equal "Men", Category.expand_abbreviations("Men:"), "Men:"

      assert_equal "Beginner Men", Category.expand_abbreviations("Beg Men"), "Beg Men"
      assert_equal "Beginner Men", Category.expand_abbreviations("Beg. Men"), "Beg. Men"
      assert_equal "Beginner Men", Category.expand_abbreviations("Beg. Men"), "Beg. Men"
      assert_equal "Beginner Men", Category.expand_abbreviations("Begin Men"), "Begin Men"
      assert_equal "Beginner Men", Category.expand_abbreviations("Beginners Men"), "Beginners Men"
      assert_equal "Beginner", Category.expand_abbreviations("Beg:"), "Beg:"
      assert_equal "Beginner", Category.expand_abbreviations("Beginning"), "Beginning"

      assert_equal "Women 30+", Category.expand_abbreviations("Women 30 & Over"), "Women 30 & Over"
      assert_equal "Women 30+", Category.expand_abbreviations("Women 30 and Over"), "Women 30 and Over"
      assert_equal "Women 30+", Category.expand_abbreviations("Women 30 and older"), "Women 30 and older"
      assert_equal "Women 30+", Category.expand_abbreviations("Women 30>"), "Women 30>"

      assert_equal "Clydesdale", Category.expand_abbreviations("Clydesdales"), "Clydesdales"

      assert_equal "Masters Men", Category.expand_abbreviations("Masters Men"), "Masters Men"
      assert_equal "Masters Men", Category.expand_abbreviations("Master's Men"), "Master's Men"
      assert_equal "Masters Men", Category.expand_abbreviations("Master Men"), "Master Men"
      assert_equal "Masters men", Category.expand_abbreviations("mstr men"), "mstr men"
      assert_equal "Masters Men", Category.expand_abbreviations("Mas Men"), "Mas Men"
      assert_equal "Masters", Category.expand_abbreviations("Mas"), "Mas"
      assert_equal "Masters Men", Category.expand_abbreviations("Mast. Men"), "Mast. Men"
      assert_equal "Masters Men", Category.expand_abbreviations("Mast Men"), "Mast Men"
      assert_equal "Masters Men", Category.expand_abbreviations("Maasters Men"), "Maasters Men"
      assert_equal "Masters Men", Category.expand_abbreviations("Mastes Men"), "Mastes Men"
      assert_equal "Masters Men", Category.expand_abbreviations("Mastres Men"), "Mastres Men"
      assert_equal "Masters Men", Category.expand_abbreviations("Mater Men"), "Mater Men"

      assert_equal "Expert Men", Category.expand_abbreviations("Exp. Men"), "Exp. Men"
      assert_equal "Sport Men", Category.expand_abbreviations("Sprt Men"), "Sprt Men"
      assert_equal "Veteran Men", Category.expand_abbreviations("Veteren Men"), "Veteren Men"
      assert_equal "Veteran Men", Category.expand_abbreviations("Veterans Men"), "Veterans Men"
      assert_equal "Veteran Men", Category.expand_abbreviations("Vet Men"), "Vet Men"
      assert_equal "Veteran Men", Category.expand_abbreviations("Vet. Men"), "Vet. Men"

      assert_equal "Singlespeed", Category.expand_abbreviations("Singlespeed"), "Singlespeed"
      assert_equal "Singlespeed", Category.expand_abbreviations("Singlespeeds"), "Singlespeeds"
      assert_equal "Singlespeed", Category.expand_abbreviations("SS"), "SS"
      assert_equal "Singlespeed", Category.expand_abbreviations("Single Speed"), "Single Speed"
      assert_equal "Singlespeed", Category.expand_abbreviations("Single Speeds"), "Single Speeds"
      assert_equal "Singlespeed", Category.expand_abbreviations("Sgl Spd"), "Sgl Spd"
      assert_equal "Singlespeed", Category.expand_abbreviations("Sgl Speed"), "Sgl Speed"
      assert_equal "Singlespeed/Fixed", Category.expand_abbreviations("Single Speed/Fixed"), "Single Speed/Fixed"

      assert_equal "Senior Women", Category.expand_abbreviations("Senoir Women"), "Senoir Women"
      assert_equal "Senior Women", Category.expand_abbreviations("Sr Women"), "Sr Women"
      assert_equal "Senior Women", Category.expand_abbreviations("Sr. Women"), "Sr. Women"

      assert_equal "Tandem", Category.expand_abbreviations("Tan"), "Tan"
      assert_equal "Tandem", Category.expand_abbreviations("Tand"), "Tand"
      assert_equal "Tandem", Category.expand_abbreviations("Tandems"), "Tandems"

      assert_equal "U18", Category.expand_abbreviations("18 and Under"), "18 and Under"
      assert_equal "U18", Category.expand_abbreviations("18 Under"), "18 Under"
      assert_equal "U18", Category.expand_abbreviations("18 & Under"), "18 & Under"
      assert_equal "U14", Category.expand_abbreviations("14&Under"), "14&Under"
      assert_equal "Men U18", Category.expand_abbreviations("Men 0-18"), "Men 0-18"
      assert_equal "U14", Category.expand_abbreviations("Under 14"), "Under 14"
      assert_equal "U14", Category.expand_abbreviations("14U"), "14U"
      assert_equal "U14", Category.expand_abbreviations("14 and U"), "14 and U"
      assert_equal "Category 2 U18", Category.expand_abbreviations("Category 2 U 18"), "Category 2 U 18"
      assert_equal "U14", Category.expand_abbreviations("14& U"), "14& U"

      assert_equal "Masters Men 60+", Category.expand_abbreviations("13) Masters Men 60+"), "13) Masters Men 60+"

      assert_equal "4000m pursuit", Category.expand_abbreviations("4000M pursuit"), "4000M pursuit"
      assert_equal "500m", Category.expand_abbreviations("500M"), "500M"
      assert_equal "500m", Category.expand_abbreviations("500 M"), "500 M"
      assert_equal "5K", Category.expand_abbreviations("5 k"), "5 k"
      assert_equal "2K", Category.expand_abbreviations("2 km"), "2 km"
      assert_equal "2K", Category.expand_abbreviations("2km"), "2km"

      assert_equal "2-Person", Category.expand_abbreviations("2 Person"), "2 Person"
      assert_equal "4-Man", Category.expand_abbreviations("4 man"), "2 Man"
      assert_equal "3-Day", Category.expand_abbreviations("3 day"), "3 day"
      assert_equal "10-Mile", Category.expand_abbreviations("10 Mile"), "10 Mile"
      assert_equal "24-Hour", Category.expand_abbreviations("24 hour"), "24 hour"

      assert_equal "Category 4 Men Points Race 75 Laps", Category.expand_abbreviations("Category 4 Men Points Race 75 Laps"), "Category 4 Men Points Race 75 Laps"
      assert_equal "Flying Laps - Men", Category.expand_abbreviations("Flying Laps - Men"), "Flying Laps - Men"
      assert_equal "Flying Lap", Category.expand_abbreviations("Flying Lap"), "Flying Lap"
      assert_equal "6-Lap Scratch Junior 13-14", Category.expand_abbreviations("6-Lap Scratch Junior 13-14"), "6-Lap Scratch Junior 13-14"
      assert_equal "Junior 2-Lap 10-12 Men", Category.expand_abbreviations("Junior 2 Lap 10-12 Men"), "Junior 2 Lap 10-12 Men"
      assert_equal "Team 8-Lap", Category.expand_abbreviations("Team 8 Lap"), "Team 8 Lap"

      assert_equal "Six-day", Category.expand_abbreviations("Six-day"), "Six-day"
      assert_equal "Six-day", Category.expand_abbreviations("Six day"), "Six day"
      assert_equal "Six-day", Category.expand_abbreviations("Sixday"), "Sixday"
      assert_equal "Six-day", Category.expand_abbreviations("Six-Day"), "Six-Day"
    end
  end
end
