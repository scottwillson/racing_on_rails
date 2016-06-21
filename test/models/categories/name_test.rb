require "test_helper"

module Categories
  # :stopdoc:
  class NameTest < ActiveSupport::TestCase
    test "name should be normalized when set" do
      assert_equal "Senior Men", Category.new(name: "SENIOR MEN").name, "Senior Men"
      assert_equal "Senior Men", Category.new(name: " Senior Men ").name, "' Senior Men '"
      assert_equal "Senior Men", Category.new(name: "     Senior Men").name, "'     Senior Men'"
      assert_equal "Senior Men", Category.new(name: "Senior    Men").name, "'Senior    Men'"
      assert_equal "Senior Men", Category.new(name: "Senior  Men").name, "'Senior  Men'"
      assert_equal "Category 3 Men", Category.new(name: "cat 3 Men").name, "cat 3 Men"
      assert_equal "Masters 50+", Category.new(name: "Mas50+").name, "Mas50+"
      assert_equal "Masters Men", Category.new(name: "MasterMen").name, "MasterMen"
      assert_equal "Team 12-Hour", Category.new(name: "Team 12 Hr").name, "Team 12 Hr"
      assert_equal "Pro Women 1-3", Category.new(name: "Pro Women 1-3").name, "Pro Women 1-3"
      assert_equal "Pro 1-3", Category.new(name: "Pro 1-3").name, "Pro 1-3"
      assert_equal "Masters Men 30-34 Keirin", Category.new(name: "Masters Men 30-34 Keirin").name, "Masters Men 30-34 Keirin"
      assert_equal "Masters 50+ Category 3/4/5", Category.new(name: "Masters 50 Category 3/4/5").name, "Masters 50 Category 3/4/5"
      assert_equal "Men Pro/1/2", Category.new(name: "Men Pro, 1/2").name, "Men Pro, 1/2"
      assert_equal "Men Pro/1/2", Category.new(name: "Men Pro,1/2").name, "Men Pro,1/2"
      assert_equal "Men Pro/1/2", Category.new(name: "Men Pro 1/2").name, "Men Pro 1/2"
      assert_equal "Men Pro/1/2", Category.new(name: "Men Pro 1-2").name, "Men Pro 1-2"
      assert_equal "Men 1/2", Category.new(name: "Men1-2").name, "Men1-2"
      assert_equal "Women 1/2", Category.new(name: "W1/2").name, "W1/2"
      assert_equal "Women 4", Category.new(name: "W4").name, "W4"
      assert_equal "Women A", Category.new(name: "WomenA").name, "WomenA"
      assert_equal "Category 3 Keirin", Category.new(name: "Category 3 Keirin").name, "Category 3 Keirin"
      assert_equal "Category 3 Keirin", Category.new(name: "Category 3Keirin").name, "Category 3 Keirin"
      assert_equal "Category 3 Kilo", Category.new(name: "Category 3Kilo").name, "Category 3 Kilo"
      assert_equal "Category 2 Junior Men 15-18", Category.new(name: "CAT 2 Junior Men 15-18").name, "CAT 2 Junior Men 15-18"
      assert_equal "Clydesdale Men 200+", Category.new(name: "Clydesdale Men (200+)").name, "Clydesdale Men (200+)"
      assert_equal "Clydesdale Open 200+", Category.new(name: "Clydesdale Open (200+)").name, "Clydesdale Open (200+)"
      assert_equal "Clydesdale 200+", Category.new(name: "Clydesdale (200 Lbs+)").name, "Clydesdale Open (200 Lbs+)"
      assert_equal "Senior Women 3K Pursuit", Category.new(name: "Senior Women (3K Pursuit)").name, "Senior Women (3K Pursuit)"
      assert_equal "Senior Women 3K", Category.new(name: "Senior Women (3K)").name, "Senior Women (3K)"
      assert_equal "Junior Men 2K Pursuit", Category.new(name: "Junior Men (2k Pursuit)").name, "Junior Men (2k Pursuit)"
      assert_equal "Junior Men 10-12", Category.new(name: "Junior M 10/12").name, "Junior M 10/12"
      assert_equal "Junior B - Australian Pursuit", Category.new(name: "Junior B - Australian Pursuit").name, "Junior B - Australian Pursuit"
      assert_equal "Men U50 24-Hour", Category.new(name: "Men U50 24hr").name, "Men U50 24hr"
      assert_equal "Masters Men 30-34", Category.new(name: "Men Masters 30-34").name, "Men Masters 30-34"
      assert_equal "Masters Men 1/2/3 40+", Category.new(name: "Masters Men 1/2/3 40+").name, "Masters Men 1/2/3 40+"
      assert_equal "Masters 30-34 Kilometer", Category.new(name: "Masters 30-34 Kilometer").name, "Masters 30-34 Kilometer"
      assert_equal "4", Category.new(name: "4").name, "4"
      assert_equal "4", Category.new(name: 4).name, "4 (Number)"
    end

    test "find_or_create_by_normalized_name" do
      category = FactoryGirl.create(:category, name: "Senior Men")
      assert_equal category, Category.find_or_create_by_normalized_name(" Senior   Men  ")
    end

    test "normalize_case should set proper case" do
      assert_equal "Senior Men", Category.normalize_case("SENIOR MEN"), "SENIOR MEN"
      assert_equal "Senior Men", Category.normalize_case("senior men"), "senior men"
      assert_equal "Sport Women 40 & Over", Category.normalize_case("SPORT WOMEN 40 & OVER"), "SPORT WOMEN 40 & OVER"
      assert_equal "Jr 16-18", Category.normalize_case("JR 16-18"), "JR 16-18"
      assert_equal "CBRA", Category.normalize_case("CBRA"), "CBRA"
      assert_equal "MTB", Category.normalize_case("MTB"), "MTB"
      assert_equal "SS", Category.normalize_case("SS"), "SS"
      assert_equal "Demonstration - 500 M TT", Category.normalize_case("Demonstration - 500 m TT"), "Demonstration - 500 m TT"
      assert_equal "Pro/SemiPro", Category.normalize_case("Pro/SemiPro"), "Pro/SemiPro"
      assert_equal "Cat C/Beginner Men", Category.normalize_case("Cat C/beginner Men"), "Cat C/beginner Men"
      assert_equal "(Beginner) Cat 3 Men 13 & Under", Category.normalize_case("(beginner) Cat 3 Men 13 & Under"), "(beginner) Cat 3 Men 13 & Under"
      assert_equal "Cat II 55+", Category.normalize_case("Cat Ii 55+"), "Cat Ii 55+"
      assert_equal "Category 5A", Category.normalize_case("Category 5a"), "Category 5a"
      assert_equal "Category 5A", Category.normalize_case("Category 5A"), "Category 5A"
      assert_equal "Team of 4 - 40+", Category.normalize_case("TEAM OF 4 - 40+"), "TEAM OF 4 - 40+"
      assert_equal "TTT", Category.normalize_case("TTT"), "TTT"
      assert_equal "TT-tandem", Category.normalize_case("Tt-tandem"), "Tt-tandem"
      assert_equal "Junior TT-tandem", Category.normalize_case("Junior Tt-tandem"), "Junior Tt-tandem"
      assert_equal "Attendee", Category.normalize_case("Attendee"), "Attendee"
      assert_equal "CCX", Category.normalize_case("Ccx"), "Ccx"
      assert_equal "CX", Category.normalize_case("Cx"), "Cx"
      assert_equal "BMX", Category.normalize_case("Bmx"), "Bmx"
    end

    test "strip_whitespace" do
      assert_equal "Men 30-39", Category.strip_whitespace("Men 30 - 39"), "Men 30 - 39"
      assert_equal "Men 30-39", Category.strip_whitespace("Men 30- 39"), "Men 30- 39"
      assert_equal "Men 30-39", Category.strip_whitespace("Men 30 -39"), "Men 30 -39"

      assert_equal "Men 30+", Category.strip_whitespace("Men 30 +"), "Men 30 +"
      assert_equal "Men 30+", Category.strip_whitespace("Men 30+"), "Men 30+"

      assert_equal "U14", Category.strip_whitespace("U 14"), "U 14"
      assert_equal "U14", Category.strip_whitespace("U-14"), "U-14"

      assert_equal "Pro 1/2", Category.strip_whitespace("Pro 1 / 2"), "Pro 1 / 2"
      assert_equal "Pro 1/2", Category.strip_whitespace("Pro 1/ 2"), "Pro 1/ 2"
      assert_equal "Pro 1/2", Category.strip_whitespace("Pro 1 /2"), "Pro 1 /2"
      assert_equal "Pro/Expert Women", Category.strip_whitespace("Pro / Expert Women"), "Pro / Expert Women"

      assert_equal "6 - race", Category.strip_whitespace("6- race"), "6 - race"

      assert_equal "3", Category.strip_whitespace(3), "Number 3"
    end

    test "#normalize_punctuation" do
      assert_equal "Category 1/2", Category.normalize_punctuation("Category 1/2/"), "Category 1/2/"
      assert_equal "Category 1/2", Category.normalize_punctuation("Category 1/2:"), "Category 1/2:"
      assert_equal "Category 1/2", Category.normalize_punctuation("Category 1/2."), "Category 1/2."

      assert_equal "Category 4/5 Junior", Category.normalize_punctuation("Category 4/5 (Junior)"), "Category 4/5 (Junior)"
      assert_equal "Category 4/5 Men", Category.normalize_punctuation("Category 4/5 (Men)"), "Category 4/5 (Men)"

      assert_equal "Category 4/5", Category.normalize_punctuation("Category 4//5"), "Category 4//5"

      assert_equal "1/2/3", Category.normalize_punctuation("1 2 3"), "1 2 3"
      assert_equal "4/5", Category.normalize_punctuation("4 5"), "4 5"
      assert_equal "Men 3/4/5 50+", Category.normalize_punctuation("Men 3.4.5 50+"), "Men 3.4.5 50+"
      assert_equal "1/2", Category.normalize_punctuation("1,2"), "1,2"
      assert_equal "1/2", Category.normalize_punctuation("1-2"), "1-2"
      assert_equal "1/2/3", Category.normalize_punctuation("1,2,3"), "1,2,3"
      assert_equal "1/2/3", Category.normalize_punctuation("1-2-3"), "1-2-3"
      assert_equal "3/4/5", Category.normalize_punctuation("3.4.5"), "3.4.5"

      assert_equal "2-Person", Category.normalize_punctuation("2 Person"), "2 Person"
      assert_equal "4-Man", Category.normalize_punctuation("4 man"), "4 Man"
      assert_equal "3-Day", Category.normalize_punctuation("3 day"), "3 day"
      assert_equal "10-Mile", Category.normalize_punctuation("10 Mile"), "10 Mile"
      assert_equal "24-Hour", Category.normalize_punctuation("24 hour"), "24 hour"
      assert_equal "Four-Man Team", Category.normalize_punctuation("Four Man Team"), "Four Man Team"
      assert_equal "Junior 2-Lap 10-12 Men", Category.normalize_punctuation("Junior 2 Lap 10-12 Men"), "Junior 2 Lap 10-12 Men"
      assert_equal "Team 8-Lap", Category.normalize_punctuation("Team 8 Lap"), "Team 8 Lap"

      assert_equal "6-Lap Scratch Junior 13-14", Category.normalize_punctuation("6-Lap Scratch Junior 13-14"), "6-Lap Scratch Junior 13-14"

      assert_equal "Six-day", Category.normalize_punctuation("Six-day"), "Six-day"
      assert_equal "Six-day", Category.normalize_punctuation("Six day"), "Six day"
      assert_equal "Six-day", Category.normalize_punctuation("Sixday"), "Sixday"
      assert_equal "Six-day", Category.normalize_punctuation("Six-Day"), "Six-Day"

      assert_equal "Men 40+ B", Category.normalize_punctuation("Men 40+ - B"), "Men 40+ - B"
      assert_equal "Junior Men 12-18", Category.normalize_age_group_punctuation("Junior Men (12-18)"), "Junior Men (12-18)"
    end

    test "#replace_roman_numeral_categories" do
      assert_equal "Category 1", Category.replace_roman_numeral_categories("Category I"), "Category I"
      assert_equal "Category 2", Category.replace_roman_numeral_categories("Category II"), "Category II"
      assert_equal "Category 3", Category.replace_roman_numeral_categories("Category III"), "Category III"
      assert_equal "Category 4", Category.replace_roman_numeral_categories("Category IV"), "Category IV"
      assert_equal "Category 5", Category.replace_roman_numeral_categories("Category V"), "Category V"
    end

    test "#normalize_spelling" do
      assert_equal "Sport (Category 2) Men 14-18", Category.normalize_spelling("Sport (Cat 2) Men 14-18"), "Sport (Cat 2) Men 14-18"

      assert_equal "senior men", Category.normalize_spelling("senior men"), "senior men"
      assert_equal "Category 3", Category.normalize_spelling("Cat 3"), "Cat 3"
      assert_equal "Category 3", Category.normalize_spelling("cat 3"), "cat 3"
      assert_equal "Category 3", Category.normalize_spelling("Category 3"), "Category 3"
      assert_equal "Category 5", Category.normalize_spelling("Cat. 5"), "Cat. 5"
      assert_equal "Women (All Categories)", Category.normalize_spelling("Women (All Categories)"), "Women (All Categories)"
      assert_equal "Category 3", Category.normalize_spelling("cat3"), "cat3"
      assert_equal "Category 3", Category.normalize_spelling("Category3"), "Category3"
      assert_equal "Category 1 Men 40+", Category.normalize_spelling("Category 1MEN 40+"), "Category 1MEN 40+"
      assert_equal "Category 4 Men", Category.normalize_spelling("Category 4/ Men"), "Category 4/ Men"
      assert_equal "Category 4", Category.normalize_spelling("categegory 4"), "categegory 4"
      assert_equal "Category 4", Category.normalize_spelling("Categpry 4"), "Categpry 4"
      assert_equal "Category 4", Category.normalize_spelling("ct 4"), "ct 4"
      assert_equal "Category 4", Category.normalize_spelling("Catgory 4"), "Catgory 4"

      assert_equal "Junior 10-12", Category.normalize_spelling("Jr 10-12"), "Jr 10-12"
      assert_equal "Junior 10-12", Category.normalize_spelling("Jr. 10-12"), "Jr. 10-12"
      assert_equal "Junior 10-12", Category.normalize_spelling("Junior 10-12"), "Junior 10-12"
      assert_equal "Junior 10-12", Category.normalize_spelling("Juniors 10-12"), "Juniors 10-12"
      assert_equal "Junior 10-12", Category.normalize_spelling("Juniors: 10-12"), "Juniors: 10-12"

      assert_equal "Junior Women 13-14", Category.normalize_spelling("Jr Wm 13-14"), "Jr Wm 13-14"
      assert_equal "Junior Women 13-14", Category.normalize_spelling("Jr Wmen 13-14"), "Jr Wmen 13-14"
      assert_equal "Junior Women 13-14", Category.normalize_spelling("Jr Wmn 13-14"), "Jr Wmn 13-14"
      assert_equal "Junior Women 13-14", Category.normalize_spelling("Jr Wom 13-14"), "Jr Wom 13-14"
      assert_equal "Junior Women 13-14", Category.normalize_spelling("Jr Women 13-14"), "Jr Women 13-14"
      assert_equal "Category 3 Women 35+", Category.normalize_spelling("Cat 3 W 35+"), "Cat 3 W 35+"

      assert_equal "Men Keirin", Category.normalize_spelling("Men's Keirin"), "Men's Keirin"
      assert_equal "Men Keirin", Category.normalize_spelling("Mens Keirin"), "Mens Keirin"
      assert_equal "Women Keirin", Category.normalize_spelling("Women's Keirin"), "Men's Keirin"
      assert_equal "Women Keirin", Category.normalize_spelling("Womens Keirin"), "Mens Keirin"
      assert_equal "50+ Sport Men", Category.normalize_spelling("50+ Sport Male"), "50+ Sport Male"
      assert_equal "Beginner 19+ Women", Category.normalize_spelling("Beginner 19+ Female"), "Beginner 19+ Female"
      assert_equal "Men", Category.normalize_spelling("Men:"), "Men:"

      assert_equal "Beginner Men", Category.normalize_spelling("Beg Men"), "Beg Men"
      assert_equal "Beginner Men", Category.normalize_spelling("Beg. Men"), "Beg. Men"
      assert_equal "Beginner Men", Category.normalize_spelling("Beg. Men"), "Beg. Men"
      assert_equal "Beginner Men", Category.normalize_spelling("Begin Men"), "Begin Men"
      assert_equal "Beginner Men", Category.normalize_spelling("Beginners Men"), "Beginners Men"
      assert_equal "Beginner", Category.normalize_spelling("Beg:"), "Beg:"
      assert_equal "Beginner", Category.normalize_spelling("Beginning"), "Beginning"

      assert_equal "Women 30+", Category.normalize_spelling("Women 30 & Over"), "Women 30 & Over"
      assert_equal "Women 30+", Category.normalize_spelling("Women 30 and Over"), "Women 30 and Over"
      assert_equal "Women 30+", Category.normalize_spelling("Women 30 and older"), "Women 30 and older"
      assert_equal "Women 30+", Category.normalize_spelling("Women 30>"), "Women 30>"

      assert_equal "Co-ed", Category.normalize_spelling("Co-Ed"), "Co-Ed"
      assert_equal "Co-ed", Category.normalize_spelling("Coed"), "Coed"

      assert_equal "Clydesdale", Category.normalize_spelling("Clydesdales"), "Clydesdales"
      assert_equal "Clydesdale", Category.normalize_spelling("Clydsdales"), "Clydsdales"
      assert_equal "Clydesdale 200+", Category.normalize_spelling("Clyde 200+"), "Clyde 200+"
      assert_equal "Clydesdale", Category.normalize_spelling("Clydes"), "Clydes"

      assert_equal "Clydesdale 200+", Category.normalize_spelling("Clyde 200+ Lbs"), "Clyde 200+ Lbs"
      assert_equal "Clydesdale 210+", Category.normalize_spelling("Clyde 210+ Lbs"), "Clyde 210+ Lbs"
      assert_equal "Clydesdale 210+", Category.normalize_spelling("Clyde 210 Lbs +"), "Clyde 210 Lbs +"
      assert_equal "Clydesdale 210+", Category.normalize_spelling("Clyde 210lbs+"), "Clyde 210lbs+"
      assert_equal "Clydesdale 200+", Category.normalize_spelling("Clyde 200 Lbs+"), "Clyde 200 Lbs+"
      assert_equal "Clydesdale 200+", Category.normalize_spelling("Clyde 200 Lb+"), "Clyde 200 Lb+"
      assert_equal "Clydesdale 200+", Category.normalize_spelling("Clyde 200 Lbs.+"), "Clyde 200 Lbs.+"

      assert_equal "Masters Men", Category.normalize_spelling("Masters Men"), "Masters Men"
      assert_equal "Masters Men", Category.normalize_spelling("Master's Men"), "Master's Men"
      assert_equal "Masters Men", Category.normalize_spelling("Master Men"), "Master Men"
      assert_equal "Masters men", Category.normalize_spelling("mstr men"), "mstr men"
      assert_equal "Masters Men", Category.normalize_spelling("Mas Men"), "Mas Men"
      assert_equal "Masters", Category.normalize_spelling("Mas"), "Mas"
      assert_equal "Masters Men", Category.normalize_spelling("Mast. Men"), "Mast. Men"
      assert_equal "Masters Men", Category.normalize_spelling("Mast Men"), "Mast Men"
      assert_equal "Masters Men", Category.normalize_spelling("Maasters Men"), "Maasters Men"
      assert_equal "Masters Men", Category.normalize_spelling("Mastes Men"), "Mastes Men"
      assert_equal "Masters Men", Category.normalize_spelling("Mastres Men"), "Mastres Men"
      assert_equal "Masters Men", Category.normalize_spelling("Mater Men"), "Mater Men"

      assert_equal "Expert Men", Category.normalize_spelling("Exp. Men"), "Exp. Men"
      assert_equal "Expert Men", Category.normalize_spelling("Ex Men"), "Ex Men"
      assert_equal "Expert Men", Category.normalize_spelling("Exb. Men"), "Exb. Men"
      assert_equal "Expert Men", Category.normalize_spelling("Exeprt Men"), "Exeprt Men"
      assert_equal "Expert Men", Category.normalize_spelling("Exper Men"), "Exper Men"
      assert_equal "Sport Men", Category.normalize_spelling("Sprt Men"), "Sprt Men"
      assert_equal "Veteran Men", Category.normalize_spelling("Veteren Men"), "Veteren Men"
      assert_equal "Veteran Men", Category.normalize_spelling("Veterans Men"), "Veterans Men"
      assert_equal "Veteran Men", Category.normalize_spelling("Vet Men"), "Vet Men"
      assert_equal "Veteran Men", Category.normalize_spelling("Vet. Men"), "Vet. Men"
      assert_equal "Pro/Semi-Pro", Category.normalize_spelling("Pro/SemiPro"), "Pro/SemiPro"
      assert_equal "Pro/Semi-Pro", Category.normalize_spelling("Pro/Semi Pro"), "Pro/Semi Pro"
      assert_equal "Pro/Semi-Pro", Category.normalize_spelling("Pro/Semi-Pro"), "Pro/Semi-Pro"

      assert_equal "Singlespeed", Category.normalize_spelling("Singlespeed"), "Singlespeed"
      assert_equal "Singlespeed", Category.normalize_spelling("Singlespeeds"), "Singlespeeds"
      assert_equal "Singlespeed", Category.normalize_spelling("SS"), "SS"
      assert_equal "Singlespeed", Category.normalize_spelling("Single Speed"), "Single Speed"
      assert_equal "Singlespeed", Category.normalize_spelling("Single Speeds"), "Single Speeds"
      assert_equal "Singlespeed", Category.normalize_spelling("Sgl Spd"), "Sgl Spd"
      assert_equal "Singlespeed", Category.normalize_spelling("Sgl Speed"), "Sgl Speed"
      assert_equal "Singlespeed/Fixed", Category.normalize_spelling("Single Speed/Fixed"), "Single Speed/Fixed"

      assert_equal "Senior Women", Category.normalize_spelling("Senoir Women"), "Senoir Women"
      assert_equal "Senior Women", Category.normalize_spelling("Sr Women"), "Sr Women"
      assert_equal "Senior Women", Category.normalize_spelling("Sr. Women"), "Sr. Women"

      assert_equal "Tandem", Category.normalize_spelling("Tan"), "Tan"
      assert_equal "Tandem", Category.normalize_spelling("Tand"), "Tand"
      assert_equal "Tandem", Category.normalize_spelling("Tandems"), "Tandems"

      assert_equal "U18", Category.normalize_spelling("18 and Under"), "18 and Under"
      assert_equal "U18", Category.normalize_spelling("18 Under"), "18 Under"
      assert_equal "U18", Category.normalize_spelling("18 & Under"), "18 & Under"
      assert_equal "U14", Category.normalize_spelling("14&Under"), "14&Under"
      assert_equal "Men U18", Category.normalize_spelling("Men 0-18"), "Men 0-18"
      assert_equal "U14", Category.normalize_spelling("Under 14"), "Under 14"
      assert_equal "U14", Category.normalize_spelling("14U"), "14U"
      assert_equal "U14", Category.normalize_spelling("14 and U"), "14 and U"
      assert_equal "Category 2 U18", Category.normalize_spelling("Category 2 U 18"), "Category 2 U 18"
      assert_equal "U14", Category.normalize_spelling("14& U"), "14& U"
      assert_equal "U18", Category.normalize_spelling("18 and Younger"), "18 and Younger"

      assert_equal "Masters Men 60+", Category.normalize_spelling("13) Masters Men 60+"), "13) Masters Men 60+"

      assert_equal "4000m pursuit", Category.normalize_spelling("4000M pursuit"), "4000M pursuit"
      assert_equal "500m", Category.normalize_spelling("500M"), "500M"
      assert_equal "500m", Category.normalize_spelling("500 M"), "500 M"
      assert_equal "5K", Category.normalize_spelling("5 k"), "5 k"
      assert_equal "2K", Category.normalize_spelling("2 km"), "2 km"
      assert_equal "2K", Category.normalize_spelling("2km"), "2km"
      assert_equal "200m", Category.normalize_spelling("200 meter"), "200 meter"

      assert_equal "Category 4 Men Points Race 75 Laps", Category.normalize_spelling("Category 4 Men Points Race 75 Laps"), "Category 4 Men Points Race 75 Laps"
      assert_equal "Flying Laps - Men", Category.normalize_spelling("Flying Laps - Men"), "Flying Laps - Men"
      assert_equal "Flying Lap", Category.normalize_spelling("Flying Lap"), "Flying Lap"
      assert_equal "Miss and Out", Category.normalize_spelling("Miss N' Out"), "Miss N' Out"
      assert_equal "Miss and Out", Category.normalize_spelling("Miss-n-Out"), "Miss-n-Out"

      assert_equal "Hardtail", Category.normalize_spelling("Hard tail"), "Hard tail"
      assert_equal "Ironman", Category.normalize_spelling("Iron man"), "Iron man"
      assert_equal "Hotspot", Category.normalize_spelling("Hot spot"), "Hot spot"

      assert_equal "Varsity", Category.normalize_spelling("Vsty"), "Vsty"
      assert_equal "Junior Varsity", Category.normalize_spelling("JV"), "JV"
      assert_equal "Junior Varsity", Category.normalize_spelling("Jv"), "Jv"
      assert_equal "Junior Varsity", Category.normalize_spelling("Varsity Junior"), "Varsity Junior"

      assert_equal "Men 2/3/4", Category.normalize_spelling("M 234"), "M 234"
      assert_equal "Men 3", Category.normalize_spelling("M 3"), "M 3"
      assert_equal "Men 4/5", Category.normalize_spelling("M 4/5"), "M 4/5"
      assert_equal "Men Pro/1/2", Category.normalize_spelling("M P/1/2"), "M P/1/2"

      assert_equal "Masters 30+", Category.normalize_spelling("M 30+"), "M 30+"
      assert_equal "Masters Men 30+", Category.normalize_spelling("Mm 30+"), "Mm 30+"

      assert_equal "Men 4/5", Category.normalize_spelling("Men 4/5s"), "Men 4/5s"
      assert_equal "Pro/1/2", Category.normalize_spelling("Pr/1/2"), "Pr/1/2"
    end

    test "#split_camelcase" do
      assert_equal "Junior Men", Category.split_camelcase("JuniorMen"), "JuniorMen"
      assert_equal "Master Men", Category.split_camelcase("MasterMen"), "MasterMen"
      assert_equal "SENIOR MEN", Category.split_camelcase("SENIOR MEN"), "SENIOR MEN"
      assert_equal "senior men", Category.split_camelcase("senior men"), "senior men"
      assert_equal "Singlespeed/Fixed", Category.split_camelcase("Singlespeed/Fixed"), "Singlespeed/Fixed"
      assert_equal "Men 30+", Category.split_camelcase("Men30+"), "Men30+"
      assert_equal "Women 30+", Category.split_camelcase("Women30+"), "Women30+"
    end
  end
end
