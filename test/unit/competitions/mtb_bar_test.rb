require File.expand_path("../../../test_helper", __FILE__)

class MtbBarTest < ActiveSupport::TestCase
  def test_no_masters_or_junior_ability_categories
    Discipline.reset
    Discipline.create! :name => "Super D"
    
    expert_junior_men = categories(:expert_junior_men)
    junior_men = categories(:junior_men)
    sport_junior_men = categories(:sport_junior_men)

    marin_knobular = SingleDayEvent.create!(:name => "Marin Knobular", :date => Date.new(2001, 9, 7), :discipline => "Mountain Bike")
    race = marin_knobular.races.create!(:category => expert_junior_men)
    kc = Person.create!(:name => "KC Mautner", :member_from => Date.new(2001, 1, 1))
    vanilla = teams(:vanilla)
    race.results.create!(:person => kc, :place => 4, :team => vanilla)
    chris_woods = Person.create!(:name => "Chris Woods", :member_from => Date.new(2001, 1, 1))
    gentle_lovers = teams(:gentle_lovers)
    race.results.create!(:person => chris_woods, :place => 12, :team => gentle_lovers)
    
    lemurian = SingleDayEvent.create!(:name => "Lemurian", :date => Date.new(2001, 9, 14), :discipline => "Super D")
    race = lemurian.races.create!(:category => sport_junior_men)
    race.results.create!(:person => chris_woods, :place => 14, :team => gentle_lovers)

    Bar.calculate!(2001)
    mtb_bar = Bar.find_by_year_and_discipline(2001, "Mountain Bike")
    assert_not_nil(mtb_bar, "2001 MTB BAR after calculate!")
    junior_men_mtb_bar = mtb_bar.races.detect {|b| b.name == "Junior Men" }

    assert_equal(2, junior_men_mtb_bar.results.size, "Junior Men BAR results")
    junior_men_mtb_bar.results.sort! {|x, y| x.person <=> y.person}
    assert_equal(kc, junior_men_mtb_bar.results.first.person, "Junior Men BAR first result")
    assert_equal(chris_woods, junior_men_mtb_bar.results.last.person, "Junior Men BAR last result")
    assert_equal(12, junior_men_mtb_bar.results.first.points, "Junior Men BAR first points")
    assert_equal(6, junior_men_mtb_bar.results.last.points, "Junior Men BAR last points")
    assert_equal(2, junior_men_mtb_bar.results.last.scores.size, "Junior Men BAR last scores")
  end
  
  def test_numerical_mtb_categories
    # Map categories as if they were road cats
    mtb = Discipline[:mtb]
    mtb.bar_categories.clear
    
    pro_men = Category.find_or_create_by_name("Pro Men")
    senior_men = Category.find_or_create_by_name("Senior Men")
    pro_men.parent = senior_men
    pro_men.save!
    mtb.bar_categories << pro_men
    
    men_1 = Category.find_or_create_by_name("Category 1 Men")
    men_1.parent = senior_men
    men_1.save!
    mtb.bar_categories << men_1
    
    men_2 = Category.find_or_create_by_name("Category 2 Men")
    men_2.parent = senior_men
    men_2.save!
    mtb.bar_categories << men_2
    
    men_3 = Category.find_or_create_by_name("Category 3 Men")
    category_3_men = Category.find_or_create_by_name("Category 3 Men")
    mtb.bar_categories << men_3
    
    pro_women = Category.find_or_create_by_name("Pro Women")
    senior_women = Category.find_or_create_by_name("Senior Women")
    pro_women.parent = senior_women
    pro_women.save!
    mtb.bar_categories << pro_women
    
    women_1 = Category.find_or_create_by_name("Category 1 Women")
    women_1.parent = senior_women
    women_1.save!
    mtb.bar_categories << women_1
    
    women_2 = Category.find_or_create_by_name("Category 2 Women")
    women_2.parent = senior_women
    women_2.save!
    mtb.bar_categories << women_2
    
    women_3 = Category.find_or_create_by_name("Category 3 Women")
    category_3_women = Category.find_or_create_by_name("Category 3 Women")
    mtb.bar_categories << women_3
  
    mtb.save!
    
    road = Discipline[:road]
    road.bar_categories.clear
    road.bar_categories << senior_men
    road.bar_categories << category_3_men
    category_4_men = Category.find_or_create_by_name("Category 4 Men")
    category_4_5_men = Category.find_or_create_by_name("Category 4/5 Men")
    category_4_men.parent = category_4_5_men
    category_4_men.save!
    road.bar_categories << category_4_men
    category_5_men = Category.find_or_create_by_name("Category 5 Men")
    category_5_men.parent = category_4_5_men
    category_5_men.save!
    road.bar_categories << category_5_men
    road.bar_categories << senior_women
    road.bar_categories << category_3_women
    category_4_women = Category.find_or_create_by_name("Category 4 Women")
    road.bar_categories << category_4_women
    road.save!
    
    overall = Discipline[:overall]
    overall.bar_categories.clear
    overall.bar_categories << senior_men
    overall.bar_categories << category_3_men
    overall.bar_categories << category_4_5_men
    overall.bar_categories << senior_women
    overall.bar_categories << category_3_women
    overall.bar_categories << category_4_women
    overall.save!

    short_track = Discipline.create!(:name => "Short Track", :bar => true)
    short_track.bar_categories << Category.find_by_name("Category 3 Men")
    Discipline.reset

    # Create road and MTB/DH result for each category
    tonkin = people(:tonkin)
    event = SingleDayEvent.create!(:discipline => "Road")
    event.races.create!(:category => pro_men, :field_size => 6).results.create!(:place => "3", :person => tonkin)
    
    weaver = people(:weaver)
    event.races.create!(:category => men_1, :field_size => 6).results.create!(:place => "2", :person => weaver)
    
    molly = people(:molly)
    event.races.create!(:category => men_2, :field_size => 6).results.create!(:place => "5", :person => molly)
    
    alice = people(:alice)
    event.races.create!(:category => men_3, :field_size => 6).results.create!(:place => "6", :person => alice)
    
    matson = people(:matson)
    event.races.create!(:category => category_4_men, :field_size => 6).results.create!(:place => "1", :person => matson)
    
    event = SingleDayEvent.create!(:discipline => "Mountain Bike")
    event.races.create!(:category => pro_men, :field_size => 6).results.create!(:place => "14", :person => matson)
    
    dh_event = SingleDayEvent.create!(:discipline => "Downhill")
    dh_event.races.create!(:category => men_1, :field_size => 6).results.create!(:place => "7", :person => molly)
    event.races.create!(:category => men_2, :field_size => 6).results.create!(:place => "5", :person => tonkin)
    event.races.create!(:category => men_3, :field_size => 6).results.create!(:place => "4", :person => weaver)
    
    # Women road
    event = SingleDayEvent.create!(:discipline => "Road")
    woman_pro = Person.create!(:name => "Woman Pro", :member => true)
    event.races.create!(:category => pro_women, :field_size => 6).results.create!(:place => "2", :person => woman_pro)

    woman_1 = Person.create!(:name => "Woman One", :member => true)
    event.races.create!(:category => women_1, :field_size => 6).results.create!(:place => "3", :person => woman_1)

    woman_2 = Person.create!(:name => "Woman Two", :member => true)
    event.races.create!(:category => women_2, :field_size => 6).results.create!(:place => "4", :person => woman_2)

    woman_3 = Person.create!(:name => "Woman Three", :member => true)
    event.races.create!(:category => women_3, :field_size => 6).results.create!(:place => "1", :person => woman_3)

    woman_4 = Person.create!(:name => "Woman Four", :member => true)
    event.races.create!(:category => category_4_women, :field_size => 6).results.create!(:place => "3", :person => woman_4)
    
    # Women MTB
    event = SingleDayEvent.create!(:discipline => "Mountain Bike")
    event.races.create!(:category => women_1, :field_size => 6).results.create!(:place => "6", :person => woman_3)
    event.races.create!(:category => women_2, :field_size => 6).results.create!(:place => "4", :person => woman_1)
    event.races.create!(:category => women_3, :field_size => 6).results.create!(:place => "5", :person => woman_2)
    
    # Women DH
    event = SingleDayEvent.create!(:discipline => "Downhill")
    event.races.create!(:category => pro_women, :field_size => 6).results.create!(:place => "15", :person => woman_pro)
    
    # Short Track
    event = SingleDayEvent.create!(:discipline => "Short Track")
    event.races.create!(:category => men_3, :field_size => 6).results.create!(:place => "6", :person => weaver)

    original_results_count = Result.count
    Bar.calculate!
    year = Date.today.year
    bar = Bar.find_by_date(Date.new(year))
    
    OverallBar.calculate!
    overall_bar = OverallBar.find_by_date(Date.new(year))
    OverallBar.calculate!

    road_bar = Bar.find_by_year_and_discipline(year, "Road")

    senior_men_road_bar = road_bar.races.detect { |race| race.name == "Senior Men" }
    assert_equal(3, senior_men_road_bar.results.size, "Senior Men Road BAR results")
    senior_men_road_bar.results.sort!

    senior_men_3_road_bar = road_bar.races.detect { |race| race.name == "Category 3 Men" }
    assert_equal(1, senior_men_3_road_bar.results.size, "Senior Men 3 Road BAR results")

    senior_men_4_road_bar = road_bar.races.detect { |race| race.name == "Category 4 Men" }
    assert_equal(1, senior_men_4_road_bar.results.size, "Senior Men 4 Road BAR results")
    
    senior_women_road_bar = road_bar.races.detect { |race| race.name == "Senior Women" }
    assert_equal(3, senior_women_road_bar.results.size, "Senior Women Road BAR results")

    senior_women_3_road_bar = road_bar.races.detect { |race| race.name == "Category 3 Women" }
    assert_equal(1, senior_women_3_road_bar.results.size, "Senior Women 3 Road BAR results")

    senior_women_4_road_bar = road_bar.races.detect { |race| race.name == "Category 4 Women" }
    assert_equal(1, senior_women_4_road_bar.results.size, "Senior Women 4 Road BAR results")

    assert_equal(people(:weaver), senior_men_road_bar.results[0].person, "Senior Men Road BAR results person")
    assert_equal(people(:tonkin), senior_men_road_bar.results[1].person, "Senior Men Road BAR results person")
    assert_equal(people(:molly), senior_men_road_bar.results[2].person, "Senior Men Road BAR results person")
    assert_equal(people(:alice), senior_men_3_road_bar.results[0].person, "Senior Men 3 Road BAR results person")
    assert_equal(people(:matson), senior_men_4_road_bar.results[0].person, "Senior Men 4 Road BAR results person")
    assert_equal(woman_pro, senior_women_road_bar.results[0].person, "Senior Woman Road BAR results person")
    assert_equal(woman_1, senior_women_road_bar.results[1].person, "Senior Woman Road BAR results person")
    assert_equal(woman_2, senior_women_road_bar.results[2].person, "Senior Woman Road BAR results person")
    assert_equal(woman_3, senior_women_3_road_bar.results[0].person, "Senior Woman 3 Road BAR results person")
    assert_equal(woman_4, senior_women_4_road_bar.results[0].person, "Senior Woman 4 Road BAR results person")
    
    mtb_bar = Bar.find_by_year_and_discipline(year, "Mountain Bike")
    mtb_bar_pro_men_bar = mtb_bar.races.detect { |race| race.name == "Pro Men" }
    assert_equal(1, mtb_bar_pro_men_bar.results.size, "Pro Men MTB BAR results")
    assert_equal(people(:matson), mtb_bar_pro_men_bar.results[0].person, "Pro Men MTB BAR results person")

    mtb_bar_men_1_bar = mtb_bar.races.detect { |race| race.name == "Category 1 Men" }
    assert_equal(1, mtb_bar_men_1_bar.results.size, "Men 1 MTB BAR results")
    assert_equal(people(:molly), mtb_bar_men_1_bar.results[0].person, "Men 1 MTB BAR results person")

    mtb_bar_men_2 = mtb_bar.races.detect { |race| race.name == "Category 2 Men" }
    assert_equal(1, mtb_bar_men_2.results.size, "Men 2 MTB BAR results")
    assert_equal(people(:tonkin), mtb_bar_men_2.results[0].person, "Men 2 MTB BAR results person")

    mtb_bar_men_3_bar = mtb_bar.races.detect { |race| race.name == "Category 3 Men" }
    assert_equal(1, mtb_bar_men_3_bar.results.size, "Men 3 MTB BAR results")
    assert_equal(people(:weaver), mtb_bar_men_3_bar.results[0].person, "Men 3 MTB BAR results person")

    mtb_bar_pro_women_bar = mtb_bar.races.detect { |race| race.name == "Pro Women" }
    assert_equal(1, mtb_bar_pro_women_bar.results.size, "Pro Women MTB BAR results")
    assert_equal(woman_pro, mtb_bar_pro_women_bar.results[0].person, "Pro Women MTB BAR results person")

    mtb_bar_women_2_bar = mtb_bar.races.detect { |race| race.name == "Category 2 Women" }
    assert_equal(1, mtb_bar_women_2_bar.results.size, "Women 2 MTB BAR results")
    assert_equal(woman_1, mtb_bar_women_2_bar.results[0].person, "Women 2 MTB BAR results person")
    
    short_track_bar = Bar.find_by_year_and_discipline(year, "Short Track")
    short_track_bar_men_3_bar = short_track_bar.races.detect { |race| race.name == "Category 3 Men" }
    assert_equal(1, short_track_bar_men_3_bar.results.size, "Men 3 Short Track BAR results")
    assert_equal(people(:weaver), short_track_bar_men_3_bar.results[0].person, "Men 3 Short Track BAR results person")

    senior_men_overall_bar = overall_bar.races.detect { |race| race.name == "Senior Men" }
    assert_equal(4, senior_men_overall_bar.results.size, "Senior Men Overall BAR results")
    senior_men_overall_bar.results.sort!

    senior_men_3_overall_bar = overall_bar.races.detect { |race| race.name == "Category 3 Men" }
    assert_equal(2, senior_men_3_overall_bar.results.size, "Senior Men 3 Overall BAR results")
    senior_men_3_overall_bar.results.sort!

    senior_men_4_5_overall_bar = overall_bar.races.detect { |race| race.name == "Category 4/5 Men" }
    assert_equal(3, senior_men_4_5_overall_bar.results.size, "Senior Men 4/5 Overall BAR results")
    senior_men_4_5_overall_bar.results.sort!

    senior_women_overall_bar = overall_bar.races.detect { |race| race.name == "Senior Women" }
    assert_equal(4, senior_women_overall_bar.results.size, "Senior Women Overall BAR results")
    senior_women_overall_bar.results.sort!

    senior_women_3_overall_bar = overall_bar.races.detect { |race| race.name == "Category 3 Women" }
    assert_equal(2, senior_women_3_overall_bar.results.size, "Senior Women 3 Overall BAR results")

    senior_women_4_overall_bar = overall_bar.races.detect { |race| race.name == "Category 4 Women" }
    assert_equal(2, senior_women_4_overall_bar.results.size, "Category 4 Women Overall BAR results")

    assert([people(:matson), people(:weaver)].include?(senior_men_overall_bar.results[0].person), "Senior Men Overall BAR results person")
    assert_equal("1", senior_men_overall_bar.results[0].place, "Senior Men Overall BAR results place")
    assert_equal(300, senior_men_overall_bar.results[0].points, "weaver Senior Men Overall BAR results points")
    assert_equal(1, senior_men_overall_bar.results[0].scores.size, "weaver Overall BAR results scores")

    assert([people(:matson), people(:weaver)].include?(senior_men_overall_bar.results[1].person), "Senior Men Overall BAR results person")
    assert_equal("1", senior_men_overall_bar.results[1].place, "Senior Men Overall BAR results place")
    assert_equal(300, senior_men_overall_bar.results[1].points, "Tonkin Senior Men Overall BAR results points")
    assert_equal(1, senior_men_overall_bar.results[1].scores.size, "Tonkin Overall BAR results scores")

    assert_equal(people(:tonkin), senior_men_overall_bar.results[2].person, "Senior Men Overall BAR results person")
    assert_equal("3", senior_men_overall_bar.results[2].place, "Senior Men Overall BAR results place")
    assert_equal(299, senior_men_overall_bar.results[2].points, "molly Senior Men Overall BAR results points")
    assert_equal(1, senior_men_overall_bar.results[2].scores.size, "molly Overall BAR results scores")

    assert_equal(people(:molly), senior_men_overall_bar.results[3].person, "Senior Men Overall BAR results person")
    assert_equal("4", senior_men_overall_bar.results[3].place, "Senior Men Overall BAR results place")
    assert_equal(298, senior_men_overall_bar.results[3].points, "molly Senior Men Overall BAR results points")
    assert_equal(1, senior_men_overall_bar.results[3].scores.size, "molly Overall BAR results scores")

    assert([people(:alice), people(:molly)].include?(senior_men_3_overall_bar.results[0].person), "Senior Men Overall BAR results person")
    assert_equal("1", senior_men_3_overall_bar.results[0].place, "Senior Men Overall BAR results place")
    assert_equal(300, senior_men_3_overall_bar.results[0].points, "alice Senior Men Overall BAR results points")
    assert_equal(1, senior_men_3_overall_bar.results[0].scores.size, "alice Overall BAR results scores")

    assert([people(:alice), people(:molly)].include?(senior_men_3_overall_bar.results[1].person), "Senior Men Overall BAR results person")
    assert_equal("1", senior_men_3_overall_bar.results[1].place, "Senior Men Overall BAR results place")
    assert_equal(300, senior_men_3_overall_bar.results[1].points, "alice Senior Men Overall BAR results points")
    assert_equal(1, senior_men_3_overall_bar.results[1].scores.size, "alice Overall BAR results scores")

    senior_men_4_5_overall_bar.results.sort
    assert_equal people(:weaver), senior_men_4_5_overall_bar.results[0].person, "Senior Men Overall BAR results person"
    assert_equal("1", senior_men_4_5_overall_bar.results[0].place, "Senior Men Overall BAR results place")
    assert_equal(600, senior_men_4_5_overall_bar.results[0].points, "matson Senior Men Overall BAR results points")
    assert_equal(2, senior_men_4_5_overall_bar.results[0].scores.size, "matson Overall BAR results scores")

    assert([people(:matson), people(:weaver), people(:tonkin)].include?(senior_men_4_5_overall_bar.results[1].person), "Senior Men Overall BAR results person")
    assert_equal("2", senior_men_4_5_overall_bar.results[1].place, "Senior Men Overall BAR results place")
    assert_equal(300, senior_men_4_5_overall_bar.results[1].points, "matson Senior Men Overall BAR results points")
    assert_equal(1, senior_men_4_5_overall_bar.results[1].scores.size, "matson Overall BAR results scores")

    assert([people(:matson), people(:weaver), people(:tonkin)].include?(senior_men_4_5_overall_bar.results[2].person), "Senior Men Overall BAR results person")
    assert_equal("2", senior_men_4_5_overall_bar.results[2].place, "Senior Men Overall BAR results place")
    assert_equal(300, senior_men_4_5_overall_bar.results[2].points, "matson Senior Men Overall BAR results points")
    assert_equal(1, senior_men_4_5_overall_bar.results[2].scores.size, "matson Overall BAR results scores")
    
    assert_equal(woman_pro, senior_women_overall_bar.results[0].person, "Senior Women Overall BAR results person")
    assert_equal("1", senior_women_overall_bar.results[0].place, "Senior Women Overall BAR results place")
    assert_equal(600, senior_women_overall_bar.results[0].points, "Senior Women Overall BAR results points")
    assert_equal(2, senior_women_overall_bar.results[0].scores.size, "Senior Women Overall BAR results scores")
    
    assert_equal(woman_3, senior_women_overall_bar.results[1].person, "Senior Women Overall BAR results person")
    assert_equal("2", senior_women_overall_bar.results[1].place, "Senior Women Overall BAR results place")
    assert_equal(300, senior_women_overall_bar.results[1].points, "Senior Women Overall BAR results points")
    assert_equal(1, senior_women_overall_bar.results[1].scores.size, "Women Overall BAR results scores")
    
    assert_equal(woman_1, senior_women_overall_bar.results[2].person, "Senior Women Overall BAR results person")
    assert_equal("3", senior_women_overall_bar.results[2].place, "Senior Women Overall BAR results place")
    assert_equal(299, senior_women_overall_bar.results[2].points, "Senior Women Overall BAR results points")
    assert_equal(1, senior_women_overall_bar.results[2].scores.size, "Women Overall BAR results scores")
    
    assert_equal(woman_2, senior_women_overall_bar.results[3].person, "Senior Women Overall BAR results person")
    assert_equal("4", senior_women_overall_bar.results[3].place, "Senior Women Overall BAR results place")
    assert_equal(298, senior_women_overall_bar.results[3].points, "Senior Women Overall BAR results points")
    assert_equal(1, senior_women_overall_bar.results[3].scores.size, "Women Overall BAR results scores")
    
    assert([woman_1, woman_3].include?(senior_women_3_overall_bar.results[0].person), "Senior Women 3 Overall BAR results person")
    assert_equal("1", senior_women_3_overall_bar.results[0].place, "Senior Women 3 Overall BAR results place")
    assert_equal(300, senior_women_3_overall_bar.results[0].points, "Senior Women 3 Overall BAR results points")
    assert_equal(1, senior_women_3_overall_bar.results[0].scores.size, "Women 3 Overall BAR results scores")
    
    assert([woman_1, woman_3].include?(senior_women_3_overall_bar.results[0].person), "Senior Women 3 Overall BAR results person")
    assert_equal("1", senior_women_3_overall_bar.results[0].place, "Senior Women 3 Overall BAR results place")
    assert_equal(300, senior_women_3_overall_bar.results[0].points, "Senior Women 3 Overall BAR results points")
    assert_equal(1, senior_women_3_overall_bar.results[0].scores.size, "Women 3 Overall BAR results scores")
    
    assert([woman_2, woman_4].include?(senior_women_4_overall_bar.results[0].person), "Senior Women Overall BAR results person")
    assert_equal("1", senior_women_4_overall_bar.results[0].place, "Senior Women Overall BAR results place")
    assert_equal(300, senior_women_4_overall_bar.results[0].points, "Senior Women Overall BAR results points")
    assert_equal(1, senior_women_4_overall_bar.results[0].scores.size, "Women Overall BAR results scores")
    
    assert([woman_2, woman_4].include?(senior_women_4_overall_bar.results[0].person), "Senior Women Overall BAR results person")
    assert_equal("1", senior_women_4_overall_bar.results[0].place, "Senior Women Overall BAR results place")
    assert_equal(300, senior_women_4_overall_bar.results[0].points, "Senior Women Overall BAR results points")
    assert_equal(1, senior_women_4_overall_bar.results[0].scores.size, "Women Overall BAR results scores")

    assert_equal(original_results_count + 36, Result.count, "Total count of results in DB after BARs calculate!")
  end
  
  def test_masters_state_champs
    event = SingleDayEvent.create!(:name => "Mudslinger", :date => Date.new(2001, 9, 7), :discipline => "Mountain Bike", :bar_points => 2)
    masters_men = categories(:masters_men)
    masters_men_45_54 = masters_men.children.create!(:name => "Masters Men 45 -54")
    race = event.races.create!(:category => masters_men_45_54)
    kc = Person.create!(:name => "KC Mautner", :member_from => Date.new(2001, 1, 1))
    vanilla = teams(:vanilla)
    race.results.create!(:person => kc, :place => 4, :team => vanilla)

    mtb = Discipline[:mtb]
    mtb.bar_categories << masters_men
    Bar.calculate!(2001)
    mtb_bar = Bar.find_by_year_and_discipline(2001, "Mountain Bike")
    assert_not_nil(mtb_bar, "2001 MTB BAR after calculate!")
    masters_mtb_bar = mtb_bar.races.detect { |b| b.name == "Masters Men" }

    assert_equal(1, masters_mtb_bar.results.size, "Masters Men BAR results")
    assert_equal(kc, masters_mtb_bar.results.first.person, "Masters Men BAR first result")
    assert_equal(24, masters_mtb_bar.results.first.points, "Masters Men BAR first points")
  end
end
