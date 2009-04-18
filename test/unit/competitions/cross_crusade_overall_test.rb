require "test_helper"

class CrossCrusadeOverallTest < ActiveSupport::TestCase  
  def test_recalc_with_no_series
    competition_count = Competition.count
    CrossCrusadeOverall.calculate!
    CrossCrusadeOverall.calculate!(2007)
    assert_equal(competition_count, Competition.count, "Should add no new Competition if there are no Cross Crusade events")
  end

  def test_recalc_with_one_event
    series = Series.create!(:name => "Cross Crusade")
    event = series.children.create!(:date => Date.new(2007, 10, 7), :name => "Cross Crusade #4")

    series.children.create!(:date => Date.new(2007, 10, 14))
    series.children.create!(:date => Date.new(2007, 10, 21))
    series.children.create!(:date => Date.new(2007, 10, 28))
    series.children.create!(:date => Date.new(2007, 11, 5))
    
    series.reload
    assert_equal(Date.new(2007, 10, 7), series.date, "Series date")
    
    cat_a = Category.find_or_create_by_name("Category A")
    cat_a_race = event.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 1, :racer => racers(:weaver))
    cat_a_race.results.create!(:place => 9, :racer => racers(:tonkin))

    masters_35_plus_women = Category.find_or_create_by_name("Masters Women 35+")
    masters_race = event.races.create!(:category => masters_35_plus_women)
    masters_race.results.create!(:place => 15, :racer => racers(:alice))
    masters_race.results.create!(:place => 19, :racer => racers(:molly))
    
    # Previous year should be ignored
    previous_event = Series.create!(:name => "Cross Crusade").children.create!(:date => Date.new(2006), :name => "Cross Crusade #3")
    previous_event.races.create!(:category => cat_a).results.create!(:place => 6, :racer => racers(:weaver))
    
    # Following year should be ignored
    following_event = Series.create!(:name => "Cross Crusade").children.create!(:date => Date.new(2008))
    following_event.races.create!(:category => cat_a).results.create!(:place => 10, :racer => racers(:weaver))
    
    CrossCrusadeOverall.calculate!(2007)
    assert_equal(1, series.competitions(true).size, "Should add new Competitions to parent Series")
    overall = series.competitions.first
    assert_equal(18, overall.races.size, "Overall races")
    
    CrossCrusadeOverall.calculate!(2007)
    assert_equal(1, series.competitions(true).size, "Should add new Competition to parent Series after deleting old results")
    overall = series.competitions.first
    assert_equal(18, overall.races.size, "Overall races")
    
    assert(!overall.notes.blank?, "Should have notes about rules")
        
    cx_a_overall_race = overall.races.detect { |race| race.category == cat_a }
    assert_not_nil(cx_a_overall_race, "Should have Men A overall race")
    assert_equal(2, cx_a_overall_race.results.size, "Men A race results")
    cx_a_overall_race.results(true).sort!
    result = cx_a_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "Men A first result place")
    assert_equal(26, result.points, "Men A first result points")
    assert_equal(racers(:weaver), result.racer, "Men A first result racer")
    result = cx_a_overall_race.results.last
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("2", result.place, "Men A second result place")
    assert_equal(10, result.points, "Men A second result points (double points for last result)")
    assert_equal(racers(:tonkin), result.racer, "Men A second result racer")

    masters_35_plus_women_overall_race = overall.races.detect { |race| race.category == masters_35_plus_women }
    assert_not_nil(masters_35_plus_women_overall_race, "Should have Masters Women overall race")
    assert_equal(1, masters_35_plus_women_overall_race.results.size, "Masters Women race results")
    result = masters_35_plus_women_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "Masters Women first result place")
    assert_equal(4, result.points, "Masters Women first result points  (double points for last result)")
    assert_equal(racers(:alice), result.racer, "Masters Women first result racer")
  end

  def test_many_results
    series = Series.create!(:name => "Cross Crusade")
    masters = Category.find_or_create_by_name("Masters 35+ A")
    category_a = Category.find_or_create_by_name("Category A")
    singlespeed = Category.find_or_create_by_name("Singlespeed")
    racer = Racer.create!(:name => "John Browning")
    
    event = series.children.create!(:date => Date.new(2008, 10, 5))
    event.races.create!(:category => masters).results.create!(:place => 1, :racer => racer)
    
    event = series.children.create!(:date => Date.new(2008, 10, 12))
    event.races.create!(:category => masters).results.create!(:place => 1, :racer => racer)
    
    event = series.children.create!(:date => Date.new(2008, 10, 19))
    event.races.create!(:category => masters).results.create!(:place => 2, :racer => racer)
    event.races.create!(:category => category_a).results.create!(:place => 4, :racer => racer)
    event.races.create!(:category => singlespeed).results.create!(:place => 5, :racer => racer)
    
    event = series.children.create!(:date => Date.new(2008, 10, 26))
    event.races.create!(:category => masters).results.create!(:place => 1, :racer => racer)
    
    event = series.children.create!(:date => Date.new(2008, 11, 2))
    event.races.create!(:category => masters).results.create!(:place => 2, :racer => racer)
    
    event = series.children.create!(:date => Date.new(2008, 11, 9))
    event.races.create!(:category => masters).results.create!(:place => 1, :racer => racer)
    event.races.create!(:category => category_a).results.create!(:place => 20, :racer => racer)
    event.races.create!(:category => singlespeed).results.create!(:place => 12, :racer => racer)
    
    event = series.children.create!(:date => Date.new(2008, 11, 10))
    event.races.create!(:category => masters).results.create!(:place => 1, :racer => racer)
    
    event = series.children.create!(:date => Date.new(2008, 11, 17))
    event.races.create!(:category => masters).results.create!(:place => 3, :racer => racer)
    event.races.create!(:category => category_a).results.create!(:place => 20, :racer => racer)

    CrossCrusadeOverall.calculate!(2008)
    
    masters_overall_race = series.overall.races.detect { |race| race.category == masters }
    assert_not_nil(masters_overall_race, "Should have Masters overall race")
    masters_overall_race.results(true).sort!
    result = masters_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "place")
    assert_equal(6, result.scores.size, "Scores")
    assert_equal(26 + 26 + 0 + 26 + 0 + 26 + 26 + (16 * 2), result.points, "points")
    assert_equal(racer, result.racer, "racer")

    category_a_overall_race = series.overall.races.detect { |race| race.category == category_a }
    assert_not_nil(category_a_overall_race, "Should have Category A overall race")
    category_a_overall_race.results(true).sort!
    result = category_a_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "place")
    assert_equal(1, result.scores.size, "Scores")
    assert_equal(15, result.points, "points")
    assert_equal(racer, result.racer, "racer")

    singlespeed_overall_race = series.overall.races.detect { |race| race.category == singlespeed }
    assert_not_nil(singlespeed_overall_race, "Should have Singlespeed overall race")
    assert(singlespeed_overall_race.results.empty?, "Should not have any singlespeed results")
  end
  
  def test_preliminary_results_after_event_minimum
    series = Series.create!(:name => "Cross Crusade")
    series.children.create!(:date => Date.new(2007, 10, 7))

    series.children.create!(:date => Date.new(2007, 10, 14))
    series.children.create!(:date => Date.new(2007, 10, 21))
    series.children.create!(:date => Date.new(2007, 10, 28))
    series.children.create!(:date => Date.new(2007, 11, 5))

    cat_a = Category.find_or_create_by_name("Category A")
    cat_a_race = series.children[0].races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 1, :racer => racers(:weaver))
    cat_a_race.results.create!(:place => 2, :racer => racers(:tonkin))
    
    cat_a_race = series.children[1].races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 43, :racer => racers(:weaver))

    cat_a_race = series.children[2].races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 1, :racer => racers(:weaver))

    cat_a_race = series.children[3].races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 8, :racer => racers(:tonkin))

    CrossCrusadeOverall.calculate!(2007)
    
    category_a_overall_race = series.overall.races.detect { |race| race.category == cat_a }
    assert_not_nil(category_a_overall_race, "Should have Category A overall race")
    category_a_overall_race.results(true).sort!
    result = category_a_overall_race.results.first
    assert_equal(false, result.preliminary?, "Weaver did three races. His result should not be preliminary")
    
    result = category_a_overall_race.results.last
    assert_equal(true, result.preliminary?, "Tonkin did only two races. His result should be preliminary")
  end
  
  def test_raced_minimum_events_boundaries
    series = Series.create!(:name => "Cross Crusade")
    cat_a = Category.find_or_create_by_name("Category A")
    molly = racers(:molly)
    event = series.children.create!(:date => Date.new(2007, 10, 7))
    
    # Molly does three races in different categories
    cat_a_race = event.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 6, :racer => molly)
    single_speed_race = event.races.create!(:category => categories(:single_speed))
    single_speed_race.results.create!(:place => 8, :racer => molly)
    masters_women_race = event.races.create!(:category => categories(:masters_women))
    masters_women_race.results.create!(:place => 10, :racer => molly)
    
    cat_a_race.results.create!(:place => 17, :racer => racers(:alice))

    CrossCrusadeOverall.calculate!(2007)
    category_a_overall_race = series.overall.races.detect { |race| race.category == cat_a }
    assert(!series.overall.raced_minimum_events?(molly, category_a_overall_race), "One event. No racers have raced minimum")
    assert(!series.overall.raced_minimum_events?(racers(:alice), category_a_overall_race), "One event. No racers have raced minimum")
    
    event = series.children.create!(:date => Date.new(2007, 10, 14))
    cat_a_race = event.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 14, :racer => molly)
    cat_a_race.results.create!(:place => 6, :racer => racers(:alice))

    CrossCrusadeOverall.calculate!(2007)
    category_a_overall_race = series.overall.races.detect { |race| race.category == cat_a }
    assert(!series.overall.raced_minimum_events?(molly, category_a_overall_race), "Two events. No racers have raced minimum")
    assert(!series.overall.raced_minimum_events?(racers(:alice), category_a_overall_race), "Two events. No racers have raced minimum")

    event = series.children.create!(:date => Date.new(2007, 10, 21))
    cat_a_race = event.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => "DNF", :racer => molly)
    single_speed_race = event.races.create!(:category => categories(:single_speed))
    single_speed_race.results.create!(:place => 8, :racer => racers(:alice))
    
    CrossCrusadeOverall.calculate!(2007)
    category_a_overall_race = series.overall.races.detect { |race| race.category == cat_a }
    assert(series.overall.raced_minimum_events?(molly, category_a_overall_race), "Three events. Molly has raced minimum")
    assert(!series.overall.raced_minimum_events?(racers(:alice), category_a_overall_race), "Three events. Alice has not raced minimum")

    event = series.children.create!(:date => Date.new(2007, 10, 28))
    cat_a_race = event.races.create!(:category => cat_a)
    
    CrossCrusadeOverall.calculate!(2007)
    category_a_overall_race = series.overall.races.detect { |race| race.category == cat_a }
    assert(series.overall.raced_minimum_events?(molly, category_a_overall_race), "Four events. Molly has raced minimum")
    assert(!series.overall.raced_minimum_events?(racers(:alice), category_a_overall_race), "Four events. Alice has not raced minimum")
  end
  
  def test_minimum_events_should_handle_results_without_racer
    series = Series.create!(:name => "Cross Crusade")
    cat_a = Category.find_or_create_by_name("Category A")
    event = series.children.create!(:date => Date.new(2007, 10, 7))

    cat_a_race = event.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 17)

    CrossCrusadeOverall.calculate!(2007)
    category_a_overall_race = series.overall.races.detect { |race| race.category == cat_a }
    assert(!series.overall.raced_minimum_events?(nil, category_a_overall_race), "Nil racer should never have mnimum events")
  end
  
  def test_count_six_best_results
    series = Series.create!(:name => "Cross Crusade")
    category_a = Category.find_or_create_by_name("Category A")
    racer = Racer.create!(:name => "Kevin Hulick")

    date = Date.new(2008, 10, 19)
    [8, 3, 10, 7, 8, 7, 8].each do |place|
      series.children.create!(:date => date).races.create!(:category => category_a).results.create!(:place => place, :racer => racer)
      date = date + 7
    end
    
    # Simulate 7 of 8 events. Last, double-point event still in future
    series.children.create!(:date => date).races.create!(:category => category_a)
    
    CrossCrusadeOverall.calculate!(2008)
    
    category_a_overall_race = series.overall.races.detect { |race| race.category == category_a }
    assert_not_nil(category_a_overall_race, "Should have Category A overall race")
    category_a_overall_race.results(true).sort!
    result = category_a_overall_race.results.first
    assert_equal(6, result.scores.size, "Scores")
    assert_equal(16 + 12 + 12 + 11 + 11 + 11, result.points, "points")
  end
  
  def test_choose_best_results_by_points_not_place
    series = Series.create!(:name => "Cross Crusade")
    category_a = Category.find_or_create_by_name("Category A")
    racer = Racer.create!(:name => "Kevin Hulick")

    date = Date.new(2008, 10, 19)
    [8, 8, 8, 7, 6, 8, 7, 9].each do |place|
      series.children.create!(:date => date).races.create!(:category => category_a).results.create!(:place => place, :racer => racer)
      date = date + 7
    end

    CrossCrusadeOverall.calculate!(2008)
    
    category_a_overall_race = series.overall.races.detect { |race| race.category == category_a }
    assert_not_nil(category_a_overall_race, "Should have Category A overall race")
    category_a_overall_race.results(true).sort!
    result = category_a_overall_race.results.first
    assert_equal(6, result.scores.size, "Scores")
    assert_equal(11 + 12 + 13 + 11 + 12 + 20, result.points, "points")
  end
  
  def test_ensure_dnf_sorted_correctly
    series = Series.create!(:name => "Cross Crusade")
    category_a = Category.find_or_create_by_name("Category A")
    racer = Racer.create!(:name => "Kevin Hulick")

    date = Date.new(2008, 10, 19)
    [8, 3, 10, "DNF", 8, 7, 8].each do |place|
      series.children.create!(:date => date).races.create!(:category => category_a).results.create!(:place => place, :racer => racer)
      date = date + 7
    end
    
    # Simulate 7 of 8 events. Last, double-point, event, still in future
    series.children.create!(:date => date).races.create!(:category => category_a)
    
    CrossCrusadeOverall.calculate!(2008)
    
    category_a_overall_race = series.overall.races.detect { |race| race.category == category_a }
    assert_not_nil(category_a_overall_race, "Should have Category A overall race")
    category_a_overall_race.results(true).sort!
    result = category_a_overall_race.results.first
    assert_equal(6, result.scores.size, "Scores")
    assert_equal(16 + 12 + 11 + 11 + 11 + 9, result.points, "points")
  end

  def test_ignore_age_graded_bar
    series = Series.create!(:name => "Cross Crusade")
    cat_a = Category.find_or_create_by_name("Category A")
    series.children.create!(:date => Date.new(2007, 10, 7))
    event = series.children.create!(:date => Date.new(2007, 10, 14))

    cat_a_race = event.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 17, :racer => racers(:alice))

    age_graded_race = AgeGradedBar.create!(:name => "Age Graded Results for BAR/Championships").races.create!(:category => cat_a)
    age_graded_race.results.create!(:place => 1, :racer => racers(:alice))

    CrossCrusadeOverall.calculate!(2007)
    
    category_a_overall_race = series.overall.races.detect { |race| race.category == cat_a }
    assert_equal(1, category_a_overall_race.results.size, "Cat A results")
    assert_equal(1, category_a_overall_race.results.first.scores.size, "Should ignore age-graded BAR")
  end

  def test_should_not_count_for_bar_nor_ironman
    series = Series.create!(:name => "Cross Crusade")
    category_a = Category.find_or_create_by_name("Category A")
    series.children.create!(:date => Date.new(2008)).races.create!(:category => category_a).results.create!(:place => "4", :racer => racers(:tonkin))

    CrossCrusadeOverall.calculate!(2008)
    series.reload
    
    overall_results = series.overall
    assert(!overall_results.ironman, "Ironman")
    assert_equal(0, overall_results.bar_points, "BAR points")

    category_a_overall_race = overall_results.races.detect { |race| race.category == category_a }
    assert_equal(0, category_a_overall_race.bar_points, "Race BAR points")
  end  
end
