require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/cat4_womens_race_series_controller'

class Admin::Cat4WomensRaceSeriesController; def rescue_action(e) raise e end; end

class Admin::Cat4WomensRaceSeriesControllerTest < ActiveSupport::TestCase

  def setup
    @controller = Admin::Cat4WomensRaceSeriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
    @request.session[:user] = users(:candi)
  end

  def test_new_result
    assert_routing('/admin/cat4_womens_race_series/results/new', 
                   :controller => 'admin/cat4_womens_race_series', :action => 'new_result')
    
    get :new_result
    assert_response :success
  end
  
  def test_new_result_with_prepopulated_fields
    assert_routing('/admin/cat4_womens_race_series/results/new', 
                   :controller => 'admin/cat4_womens_race_series', :action => 'new_result')
    
    get :new_result, :result => { :first_name => "Kevin", :last_name => "Hulick", :team_name => "Vanilla" }
    assert_response :success

    assert_not_nil(assigns(:result), "Should assign result")
    assert_equal("Kevin", assigns(:result).first_name, "first_name")
    assert_equal("Hulick", assigns(:result).last_name, "last_name")
    assert_equal("Vanilla", assigns(:result).team_name, "team_name")
  end
  
  def test_create_result_for_new_event
    assert_routing('/admin/cat4_womens_race_series/results', 
                   {:controller => 'admin/cat4_womens_race_series', :action => 'create_result'},
                   {:method => "post"})

    post :create_result, { :result => { :place => "3", :number => "123", :team_name => "Gentle Lovers", 
                                        :first_name => "Cheryl", :last_name => "Willson" },
                           :event => { :name => "Mount Hamilton Road Race", "date(1i)" => "2009" , "date(2i)" => "4" , "date(3i)" => "1", 
                                       :sanctioned_by => ASSOCIATION.short_name},
                           :commit => "Save" 
                         }

    assert_redirected_to(:action => 'new_result')
    
    new_event = SingleDayEvent.find_by_name("Mount Hamilton Road Race")
    assert_not_nil(new_event, "Should have created Mount Hamilton Road Race")
    assert_equal_dates("2009-04-01", new_event.date, "New event date")
    assert_equal(ASSOCIATION.short_name, new_event.sanctioned_by, "Sanctioned by")

    assert_equal(1, new_event.standings.count, "New event should have one Standings")
    standings = new_event.standings.first
    assert_equal("Mount Hamilton Road Race", standings.name)

    assert_equal(1, standings.races.count, "New event standings should have one race")
    race = standings.races.first
    women_cat_4 = Category.find_by_name("Women Cat 4")
    assert_equal(women_cat_4, race.category)

    assert_equal(1, race.results.count, "New event race should have one result")
    result = race.results.first    
    assert_equal("3", result.place, "New result place")
    assert_equal("123", result.number, "New result number")
    assert_equal("Gentle Lovers", result.team_name, "New result team_name")
    assert_equal("Cheryl", result.first_name, "New result first_name")
    assert_equal("Willson", result.last_name, "New result last_name")
    assert_not_nil(flash[:info], "Should have success message in flash")
  end
  
  def test_create_result_for_existing_race_and_racers
    women_cat_4 = Category.find_or_create_by_name("Women Cat 4")
    existing_race = standings(:banana_belt).races.create!(:category => women_cat_4)
    existing_race.results.create!(:place => "1", :racer => racers(:alice))
    molly = racers(:molly)
    event = standings(:banana_belt).event

    post :create_result, { :result => { :place => "3", :number => molly.number(:road), :team_name => molly.team.name, 
                                        :first_name => molly.first_name, :last_name => molly.last_name },
                           :event => { :name => standings(:banana_belt).event.name, 
                             "date(1i)" => event.date.year.to_s,
                             "date(2i)" => event.date.month.to_s,
                             "date(3i)" => event.date.day.to_s
                            },
                           :commit => "Save" 
                         }

    assert_redirected_to(:action => 'new_result')
    
    assert_equal(1, SingleDayEvent.count(:all, :conditions => {:name => event.name}))
    new_event = SingleDayEvent.find_by_name(event.name)
    assert_equal_dates(event.date, new_event.date, "New event date")
    assert_equal(ASSOCIATION.short_name, new_event.sanctioned_by, "Sanctioned by")

    assert_equal(1, new_event.standings.count, "New event should have one Standings")
    standings = new_event.standings.first
    assert_equal("Banana Belt I", standings.name)

    assert_equal(2, standings.races.count, "New event standings should have one race: #{standings.races}")
    race = standings.races.detect {|race| race.category == women_cat_4 }
    assert_not_nil(race, "Cat 4 women's race")

    assert_equal(2, race.results.count, "race results")
    result = race.results.sort.last    
    assert_equal("3", result.place, "New result place")
    assert_equal(molly.number(:road), result.number, "New result number")
    assert_equal(molly.team_name, result.team_name, "New result team_name")
    assert_equal(molly.first_name, result.first_name, "New result first_name")
    assert_equal(molly.last_name, result.last_name, "New result last_name")
    
    assert_equal(1, Racer.count(:all, :conditions => {:last_name => molly.last_name, :first_name => molly.first_name }), "#{molly.name} in DB")
    
    assert_not_nil(flash[:info], "Should have success message in flash")
  end
  
  def test_create_result_for_existing_racer
    molly = racers(:molly)

    post :create_result, { :result => { :place => "3", :number => molly.number(:road), :team_name => molly.team.name, 
                                        :first_name => molly.first_name, :last_name => molly.last_name },
                           :event => { :name => "San Ardo Road Race", "date(1i)" => "1999" , "date(2i)" => "1" , "date(3i)" => "24" },
                           :commit => "Save" 
                         }

    assert_redirected_to(:action => 'new_result')
    
    assert_equal(1, SingleDayEvent.count(:all, :conditions => {:name => "San Ardo Road Race"}))
    new_event = SingleDayEvent.find_by_name("San Ardo Road Race")
    assert_equal_dates("1999-01-24", new_event.date, "New event date")
    assert_nil(new_event.sanctioned_by, "Sanctioned by")

    assert_equal(1, new_event.standings.count, "New event should have one Standings")
    standings = new_event.standings.first
    assert_equal("San Ardo Road Race", standings.name)

    assert_equal(1, standings.races.count, "New event standings should have one race: #{standings.races}")
    women_cat_4 = Category.find_by_name("Women Cat 4")
    race = standings.races.detect {|race| race.category == women_cat_4 }
    assert_not_nil(race, "Cat 4 women's race")

    assert_equal(1, race.results.count, "race results")
    result = race.results.sort.last    
    assert_equal("3", result.place, "New result place")
    assert_equal(molly.number(:road), result.number, "New result number")
    assert_equal(molly.team_name, result.team_name, "New result team_name")
    assert_equal(molly.first_name, result.first_name, "New result first_name")
    assert_equal(molly.last_name, result.last_name, "New result last_name")

    assert_equal(1, Racer.count(:all, :conditions => {:last_name => molly.last_name, :first_name => molly.first_name }), "#{molly.name} in DB")

    assert_not_nil(flash[:info], "Should have success message in flash")
  end

  def test_create_result_for_existing_race_with_different_category
    sr_women_4 = Category.create!(:name => "Sr. Wom 4")
    women_cat_4 = Category.find_or_create_by_name("Women Cat 4")
    women_cat_4.children << sr_women_4
    existing_race = standings(:banana_belt).races.create!(:category => sr_women_4)
    existing_race.results.create!(:place => "1", :racer => racers(:alice))
    molly = racers(:molly)
    event = standings(:banana_belt).event

    post :create_result, { :result => { :place => "3", :number => molly.number(:road), :team_name => molly.team.name, 
                                        :first_name => molly.first_name, :last_name => molly.last_name },
                           :event => { :name => standings(:banana_belt).event.name, 
                             "date(1i)" => event.date.year.to_s,
                             "date(2i)" => event.date.month.to_s,
                             "date(3i)" => event.date.day.to_s
                            },
                           :commit => "Save" 
                         }

    assert_redirected_to(:action => 'new_result')
    
    assert_equal(1, SingleDayEvent.count(:all, :conditions => {:name => event.name}))
    new_event = SingleDayEvent.find_by_name(event.name)
    assert_equal_dates(event.date, new_event.date, "New event date")
    assert_equal(ASSOCIATION.short_name, new_event.sanctioned_by, "Sanctioned by")

    assert_equal(1, new_event.standings.count, "New event should have one Standings")
    standings = new_event.standings.first
    assert_equal("Banana Belt I", standings.name)

    assert_equal(2, standings.races.count, "New event standings should have one race: #{standings.races}")
    race = standings.races.detect {|race| race.category == sr_women_4 }
    assert_not_nil(race, "Cat 4 women's race")

    assert_equal(2, race.results.count, "race results")
    result = race.results.sort.last    
    assert_equal("3", result.place, "New result place")
    assert_equal(molly.number(:road), result.number, "New result number")
    assert_equal(molly.team_name, result.team_name, "New result team_name")
    assert_equal(molly.first_name, result.first_name, "New result first_name")
    assert_equal(molly.last_name, result.last_name, "New result last_name")
    
    assert_equal(1, Racer.count(:all, :conditions => {:last_name => molly.last_name, :first_name => molly.first_name }), "#{molly.name} in DB")
    
    assert_not_nil(flash[:info], "Should have success message in flash")
  end
end