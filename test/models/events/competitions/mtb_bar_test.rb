require File.expand_path("../../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class MtbBarTest < ActiveSupport::TestCase
    test "no masters or junior ability categories" do
      FactoryGirl.create(:discipline, name: "Super D")
      mtb = FactoryGirl.create(:discipline, name: "Mountain Bike")

      junior_men        = FactoryGirl.create(:category, name: "Junior Men")
      expert_junior_men = FactoryGirl.create(:category, name: "Expert Junior Men", parent: junior_men)
      sport_junior_men  = FactoryGirl.create(:category, name: "Sport Junior Men", parent: junior_men)
      mtb.bar_categories << expert_junior_men
      mtb.bar_categories << junior_men
      mtb.bar_categories << sport_junior_men

      marin_knobular = SingleDayEvent.create!(name: "Marin Knobular", date: Date.new(2001, 9, 7), discipline: "Mountain Bike")
      race = marin_knobular.races.create!(category: expert_junior_men)
      kc = Person.create!(name: "KC Mautner", member_from: Date.new(2001, 1, 1))
      race.results.create!(person: kc, place: 4)
      chris_woods = Person.create!(name: "Chris Woods", member_from: Date.new(2001, 1, 1))
      race.results.create!(person: chris_woods, place: 12)

      lemurian = SingleDayEvent.create!(name: "Lemurian", date: Date.new(2001, 9, 14), discipline: "Super D")
      race = lemurian.races.create!(category: sport_junior_men)
      race.results.create!(person: chris_woods, place: 14)

      Bar.calculate!(2001)
      mtb_bar = Bar.find_by_year_and_discipline(2001, "Mountain Bike")
      assert_not_nil(mtb_bar, "2001 MTB BAR after calculate!")
      junior_men_mtb_bar = mtb_bar.races.detect {|b| b.name == "Junior Men" }

      assert_equal(2, junior_men_mtb_bar.results.size, "Junior Men BAR results")
      results = junior_men_mtb_bar.results.sort_by(&:person)
      assert_equal(kc, results.first.person, "Junior Men BAR first result")
      assert_equal(chris_woods, results.last.person, "Junior Men BAR last result")
      assert_equal(12, results.first.points, "Junior Men BAR first points")
      assert_equal(6, results.last.points, "Junior Men BAR last points")
      assert_equal(2, results.last.scores.size, "Junior Men BAR last scores")
    end

    test "numerical mtb categories" do
      # Map categories as if they were road cats
      mtb         = FactoryGirl.create(:discipline, name: "Mountain Bike")
      road        = FactoryGirl.create(:discipline, name: "Road")
      overall     = FactoryGirl.create(:discipline, name: "Overall")
      short_track = FactoryGirl.create(:discipline, name: "Short Track")
                    FactoryGirl.create(:discipline, name: "Downhill")

      elite_men = Category.find_or_create_by(name: "Elite Men")
      senior_men = Category.find_or_create_by(name: "Senior Men")
      elite_men.parent = senior_men
      elite_men.save!
      mtb.bar_categories << elite_men

      men_1 = Category.find_or_create_by(name: "Category 1 Men")
      men_1.parent = senior_men
      men_1.save!
      mtb.bar_categories << men_1

      men_2 = Category.find_or_create_by(name: "Category 2 Men")
      men_2.parent = senior_men
      men_2.save!
      mtb.bar_categories << men_2

      men_3 = Category.find_or_create_by(name: "Category 3 Men")
      category_3_men = Category.find_or_create_by(name: "Category 3 Men")
      mtb.bar_categories << men_3

      elite_women = Category.find_or_create_by(name: "Elite Women")
      senior_women = Category.find_or_create_by(name: "Senior Women")
      elite_women.parent = senior_women
      elite_women.save!
      mtb.bar_categories << elite_women

      women_1 = Category.find_or_create_by(name: "Category 1 Women")
      women_1.parent = senior_women
      women_1.save!
      mtb.bar_categories << women_1

      women_2 = Category.find_or_create_by(name: "Category 2 Women")
      women_2.parent = senior_women
      women_2.save!
      mtb.bar_categories << women_2

      women_3 = Category.find_or_create_by(name: "Category 3 Women")
      category_3_women = Category.find_or_create_by(name: "Category 3 Women")
      mtb.bar_categories << women_3

      mtb.save!

      road.bar_categories << senior_men
      road.bar_categories << category_3_men
      category_4_men = Category.find_or_create_by(name: "Category 4 Men")
      category_4_5_men = Category.find_or_create_by(name: "Category 4/5 Men")
      category_4_men.parent = category_4_5_men
      category_4_men.save!
      road.bar_categories << category_4_men
      category_5_men = Category.find_or_create_by(name: "Category 5 Men")
      category_5_men.parent = category_4_5_men
      category_5_men.save!
      road.bar_categories << category_5_men
      road.bar_categories << senior_women
      road.bar_categories << category_3_women
      category_4_women = Category.find_or_create_by(name: "Category 4 Women")
      road.bar_categories << category_4_women
      road.save!

      overall.bar_categories << senior_men
      overall.bar_categories << category_3_men
      overall.bar_categories << category_4_5_men
      overall.bar_categories << senior_women
      overall.bar_categories << category_3_women
      overall.bar_categories << category_4_women

      short_track.bar_categories << Category.find_by_name("Category 3 Men")

      # Create road and MTB/DH result for each category
      tonkin = FactoryGirl.create(:person)
      event = SingleDayEvent.create!(discipline: "Road")
      event.races.create!(category: elite_men, field_size: 6).results.create!(place: "3", person: tonkin)

      weaver = FactoryGirl.create(:person)
      event.races.create!(category: men_1, field_size: 6).results.create!(place: "2", person: weaver)

      molly = FactoryGirl.create(:person)
      event.races.create!(category: men_2, field_size: 6).results.create!(place: "5", person: molly)

      alice = FactoryGirl.create(:person)
      event.races.create!(category: men_3, field_size: 6).results.create!(place: "6", person: alice)

      matson = FactoryGirl.create(:person)
      event.races.create!(category: category_4_men, field_size: 6).results.create!(place: "1", person: matson)

      event = SingleDayEvent.create!(discipline: "Mountain Bike")
      event.races.create!(category: elite_men, field_size: 6).results.create!(place: "14", person: matson)

      dh_event = SingleDayEvent.create!(discipline: "Downhill")
      dh_event.races.create!(category: men_1, field_size: 6).results.create!(place: "7", person: molly)
      event.races.create!(category: men_2, field_size: 6).results.create!(place: "5", person: tonkin)
      event.races.create!(category: men_3, field_size: 6).results.create!(place: "4", person: weaver)

      # Women road
      event = SingleDayEvent.create!(discipline: "Road")
      woman_pro = Person.create!(name: "Woman Pro", member: true)
      event.races.create!(category: elite_women, field_size: 6).results.create!(place: "2", person: woman_pro)

      woman_1 = Person.create!(name: "Woman One", member: true)
      event.races.create!(category: women_1, field_size: 6).results.create!(place: "3", person: woman_1)

      woman_2 = Person.create!(name: "Woman Two", member: true)
      event.races.create!(category: women_2, field_size: 6).results.create!(place: "4", person: woman_2)

      woman_3 = Person.create!(name: "Woman Three", member: true)
      event.races.create!(category: women_3, field_size: 6).results.create!(place: "1", person: woman_3)

      woman_4 = Person.create!(name: "Woman Four", member: true)
      event.races.create!(category: category_4_women, field_size: 6).results.create!(place: "3", person: woman_4)

      # Women MTB
      event = SingleDayEvent.create!(discipline: "Mountain Bike")
      event.races.create!(category: women_1, field_size: 6).results.create!(place: "6", person: woman_3)
      event.races.create!(category: women_2, field_size: 6).results.create!(place: "4", person: woman_1)
      event.races.create!(category: women_3, field_size: 6).results.create!(place: "5", person: woman_2)

      # Women DH
      event = SingleDayEvent.create!(discipline: "Downhill")
      event.races.create!(category: elite_women, field_size: 6).results.create!(place: "15", person: woman_pro)

      # Short Track
      event = SingleDayEvent.create!(discipline: "Short Track")
      event.races.create!(category: men_3, field_size: 6).results.create!(place: "6", person: weaver)

      original_results_count = Result.count
      Bar.calculate!
      year = Time.zone.today.year
      Bar.find_by_date(Date.new(year))

      OverallBar.calculate!

      road_bar = Bar.find_by_year_and_discipline(year, "Road")

      senior_men_road_bar = road_bar.races.detect { |race| race.name == "Senior Men" }
      assert_equal(3, senior_men_road_bar.results.size, "Senior Men Road BAR results")

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

      results = senior_men_road_bar.results.sort
      assert_equal(weaver, results[0].person, "Senior Men Road BAR results person")
      assert_equal(tonkin, results[1].person, "Senior Men Road BAR results person")
      assert_equal(molly, results[2].person, "Senior Men Road BAR results person")
      assert_equal(alice, senior_men_3_road_bar.results[0].person, "Senior Men 3 Road BAR results person")
      assert_equal(matson, senior_men_4_road_bar.results[0].person, "Senior Men 4 Road BAR results person")
      assert_equal(woman_pro, senior_women_road_bar.results[0].person, "Senior Woman Road BAR results person")
      assert_equal(woman_1, senior_women_road_bar.results[1].person, "Senior Woman Road BAR results person")
      assert_equal(woman_2, senior_women_road_bar.results[2].person, "Senior Woman Road BAR results person")
      assert_equal(woman_3, senior_women_3_road_bar.results[0].person, "Senior Woman 3 Road BAR results person")
      assert_equal(woman_4, senior_women_4_road_bar.results[0].person, "Senior Woman 4 Road BAR results person")

      mtb_bar = Bar.find_by_year_and_discipline(year, "Mountain Bike")
      mtb_bar_elite_men_bar = mtb_bar.races.detect { |race| race.name == "Elite Men" }
      assert_equal(1, mtb_bar_elite_men_bar.results.size, "Elite Men MTB BAR results")
      assert_equal(matson, mtb_bar_elite_men_bar.results[0].person, "Elite Men MTB BAR results person")

      mtb_bar_men_1_bar = mtb_bar.races.detect { |race| race.name == "Category 1 Men" }
      assert_equal(1, mtb_bar_men_1_bar.results.size, "Men 1 MTB BAR results")
      assert_equal(molly, mtb_bar_men_1_bar.results[0].person, "Men 1 MTB BAR results person")

      mtb_bar_men_2 = mtb_bar.races.detect { |race| race.name == "Category 2 Men" }
      assert_equal(1, mtb_bar_men_2.results.size, "Men 2 MTB BAR results")
      assert_equal(tonkin, mtb_bar_men_2.results[0].person, "Men 2 MTB BAR results person")

      mtb_bar_men_3_bar = mtb_bar.races.detect { |race| race.name == "Category 3 Men" }
      assert_equal(1, mtb_bar_men_3_bar.results.size, "Men 3 MTB BAR results")
      assert_equal(weaver, mtb_bar_men_3_bar.results[0].person, "Men 3 MTB BAR results person")

      mtb_bar_elite_women_bar = mtb_bar.races.detect { |race| race.name == "Elite Women" }
      assert_equal(1, mtb_bar_elite_women_bar.results.size, "Elite Women MTB BAR results")
      assert_equal(woman_pro, mtb_bar_elite_women_bar.results[0].person, "Elite Women MTB BAR results person")

      mtb_bar_women_2_bar = mtb_bar.races.detect { |race| race.name == "Category 2 Women" }
      assert_equal(1, mtb_bar_women_2_bar.results.size, "Women 2 MTB BAR results")
      assert_equal(woman_1, mtb_bar_women_2_bar.results[0].person, "Women 2 MTB BAR results person")

      short_track_bar = Bar.find_by_year_and_discipline(year, "Short Track")
      short_track_bar_men_3_bar = short_track_bar.races.detect { |race| race.name == "Category 3 Men" }
      assert_equal(1, short_track_bar_men_3_bar.results.size, "Men 3 Short Track BAR results")
      assert_equal(weaver, short_track_bar_men_3_bar.results[0].person, "Men 3 Short Track BAR results person")

      overall_bar = OverallBar.find_for_year
      senior_men_overall_bar = overall_bar.races.detect { |race| race.name == "Senior Men" }
      assert_equal(4, senior_men_overall_bar.results.size, "Senior Men Overall BAR results")

      senior_men_3_overall_bar = overall_bar.races.detect { |race| race.name == "Category 3 Men" }
      assert_equal(2, senior_men_3_overall_bar.results.size, "Senior Men 3 Overall BAR results")

      senior_men_4_5_overall_bar = overall_bar.races.detect { |race| race.name == "Category 4/5 Men" }
      assert_equal(3, senior_men_4_5_overall_bar.results.size, "Senior Men 4/5 Overall BAR results")

      senior_women_overall_bar = overall_bar.races.detect { |race| race.name == "Senior Women" }
      assert_equal(4, senior_women_overall_bar.results.size, "Senior Women Overall BAR results")

      senior_women_3_overall_bar = overall_bar.races.detect { |race| race.name == "Category 3 Women" }
      assert_equal(2, senior_women_3_overall_bar.results.size, "Senior Women 3 Overall BAR results")

      senior_women_4_overall_bar = overall_bar.races.detect { |race| race.name == "Category 4 Women" }
      assert_equal(2, senior_women_4_overall_bar.results.size, "Category 4 Women Overall BAR results")

      results = senior_men_overall_bar.results.to_a.sort
      assert([matson, weaver].include?(results[0].person), "Senior Men Overall BAR results person")
      assert_equal("1", results[0].place, "Senior Men Overall BAR results place")
      assert_equal(300, results[0].points, "weaver Senior Men Overall BAR results points")
      assert_equal(1, results[0].scores.size, "weaver Overall BAR results scores")

      assert([matson, weaver].include?(results[1].person), "Senior Men Overall BAR results person")
      assert_equal("1", results[1].place, "Senior Men Overall BAR results place")
      assert_equal(300, results[1].points, "Tonkin Senior Men Overall BAR results points")
      assert_equal(1, results[1].scores.size, "Tonkin Overall BAR results scores")

      assert_equal(tonkin, results[2].person, "Senior Men Overall BAR results person")
      assert_equal("3", results[2].place, "Senior Men Overall BAR results place")
      assert_equal(299, results[2].points, "molly Senior Men Overall BAR results points")
      assert_equal(1, results[2].scores.size, "molly Overall BAR results scores")

      assert_equal(molly, results[3].person, "Senior Men Overall BAR results person")
      assert_equal("4", results[3].place, "Senior Men Overall BAR results place")
      assert_equal(298, results[3].points, "molly Senior Men Overall BAR results points")
      assert_equal(1, results[3].scores.size, "molly Overall BAR results scores")

      results = senior_men_3_overall_bar.results.to_a.sort
      assert([alice, molly].include?(results[0].person), "Senior Men Overall BAR results person")
      assert_equal("1", results[0].place, "Senior Men Overall BAR results place")
      assert_equal(300, results[0].points, "alice Senior Men Overall BAR results points")
      assert_equal(1, results[0].scores.size, "alice Overall BAR results scores")

      assert([alice, molly].include?(results[1].person), "Senior Men Overall BAR results person")
      assert_equal("1", results[1].place, "Senior Men Overall BAR results place")
      assert_equal(300, results[1].points, "alice Senior Men Overall BAR results points")
      assert_equal(1, results[1].scores.size, "alice Overall BAR results scores")

      results = senior_men_4_5_overall_bar.results.to_a.sort
      assert_equal weaver, results[0].person, "Senior Men Overall BAR results person"
      assert_equal("1", results[0].place, "Senior Men Overall BAR results place")
      assert_equal(600, results[0].points, "matson Senior Men Overall BAR results points")
      assert_equal(2, results[0].scores.size, "matson Overall BAR results scores")

      assert([matson, weaver, tonkin].include?(results[1].person), "Senior Men Overall BAR results person")
      assert_equal("2", results[1].place, "Senior Men Overall BAR results place")
      assert_equal(300, results[1].points, "matson Senior Men Overall BAR results points")
      assert_equal(1, results[1].scores.size, "matson Overall BAR results scores")

      assert([matson, weaver, tonkin].include?(results[2].person), "Senior Men Overall BAR results person")
      assert_equal("2", results[2].place, "Senior Men Overall BAR results place")
      assert_equal(300, results[2].points, "matson Senior Men Overall BAR results points")
      assert_equal(1, results[2].scores.size, "matson Overall BAR results scores")

      results = senior_women_overall_bar.results.to_a.sort
      assert_equal(woman_pro, results[0].person, "Senior Women Overall BAR results person")
      assert_equal("1", results[0].place, "Senior Women Overall BAR results place")
      assert_equal(600, results[0].points, "Senior Women Overall BAR results points")
      assert_equal(2, results[0].scores.size, "Senior Women Overall BAR results scores")

      assert_equal(woman_3, results[1].person, "Senior Women Overall BAR results person")
      assert_equal("2", results[1].place, "Senior Women Overall BAR results place")
      assert_equal(300, results[1].points, "Senior Women Overall BAR results points")
      assert_equal(1, results[1].scores.size, "Women Overall BAR results scores")

      assert_equal(woman_1, results[2].person, "Senior Women Overall BAR results person")
      assert_equal("3", results[2].place, "Senior Women Overall BAR results place")
      assert_equal(299, results[2].points, "Senior Women Overall BAR results points")
      assert_equal(1, results[2].scores.size, "Women Overall BAR results scores")

      assert_equal(woman_2, results[3].person, "Senior Women Overall BAR results person")
      assert_equal("4", results[3].place, "Senior Women Overall BAR results place")
      assert_equal(298, results[3].points, "Senior Women Overall BAR results points")
      assert_equal(1, results[3].scores.size, "Women Overall BAR results scores")

      results = senior_women_3_overall_bar.results.to_a.sort
      assert([woman_1, woman_3].include?(results[0].person), "Senior Women 3 Overall BAR results person")
      assert_equal("1", results[0].place, "Senior Women 3 Overall BAR results place")
      assert_equal(300, results[0].points, "Senior Women 3 Overall BAR results points")
      assert_equal(1, results[0].scores.size, "Women 3 Overall BAR results scores")

      assert([woman_1, woman_3].include?(results[0].person), "Senior Women 3 Overall BAR results person")
      assert_equal("1", results[0].place, "Senior Women 3 Overall BAR results place")
      assert_equal(300, results[0].points, "Senior Women 3 Overall BAR results points")
      assert_equal(1, results[0].scores.size, "Women 3 Overall BAR results scores")

      results = senior_women_4_overall_bar.results.to_a.sort
      assert([woman_2, woman_4].include?(results[0].person), "Senior Women Overall BAR results person")
      assert_equal("1", results[0].place, "Senior Women Overall BAR results place")
      assert_equal(300, results[0].points, "Senior Women Overall BAR results points")
      assert_equal(1, results[0].scores.size, "Women Overall BAR results scores")

      assert([woman_2, woman_4].include?(results[0].person), "Senior Women Overall BAR results person")
      assert_equal("1", results[0].place, "Senior Women Overall BAR results place")
      assert_equal(300, results[0].points, "Senior Women Overall BAR results points")
      assert_equal(1, results[0].scores.size, "Women Overall BAR results scores")

      assert_equal(original_results_count + 36, Result.count, "Total count of results in DB after BARs calculate!")
    end

    test "masters state champs" do
      mtb = FactoryGirl.create(:discipline, name: "Mountain Bike")
      event = SingleDayEvent.create!(name: "Mudslinger", date: Date.new(2001, 9, 7), discipline: "Mountain Bike", bar_points: 2)
      masters_men = FactoryGirl.create(:category, name: "Masters Men")
      masters_men_45_54 = masters_men.children.create!(name: "Masters Men 45 -54")
      race = event.races.create!(category: masters_men_45_54)
      kc = Person.create!(name: "KC Mautner", member_from: Date.new(2001, 1, 1))
      race.results.create!(person: kc, place: 4)

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
end
