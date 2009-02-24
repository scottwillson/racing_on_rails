# :stopdoc:
require File.dirname(__FILE__) + '/../../test_helper'

class Admin::StandingsControllerTest < ActionController::TestCase
  def setup
    super
    @request.session[:user_id] = users(:administrator).id
  end
  
  def test_edit_standings
    get(:edit, :id => standings(:jack_frost).id)
    assert_response(:success)
  end
  
  def test_edit_combined_standings
    jack_frost = standings(:jack_frost)
    jack_frost.discipline = 'Time Trial'
    jack_frost.bar_points = 2
    jack_frost.save!
    combined_standings = jack_frost.combined_standings
    get(:edit, :id => combined_standings.id)
    assert_response(:success)
  end

  def test_destroy_standings
    jack_frost = standings(:jack_frost)
    delete(:destroy, :id => jack_frost.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'jack_frost should have been destroyed') { Standings.find(jack_frost.id) }
  end

  def test_update_standings
    banana_belt = standings(:banana_belt)

    assert_not_equal('Banana Belt One', banana_belt.name, 'name')
    assert_not_equal(2, banana_belt.bar_points, 'bar_points')
    assert_not_equal('Cyclocross', banana_belt.discipline, 'discipline')

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.to_param,
         "standings"=>{"bar_points"=>"2", "name"=>"Banana Belt One", "discipline"=>"Cyclocross"}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => banana_belt.to_param)

    banana_belt.reload
    assert_equal('Banana Belt One', banana_belt.name, 'name')
    assert_equal('Cyclocross', banana_belt.discipline, 'discipline')
    assert_equal(2, banana_belt.bar_points, 'bar_points')
  end

  def test_update_discipline_nil
    banana_belt = standings(:banana_belt)
    banana_belt.update_attribute(:discipline, nil)
    assert_nil(banana_belt[:discipline], 'discipline')
    assert_equal('Road', banana_belt.event.discipline, 'Parent event discipline')

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.to_param,
         "standings"=>{"bar_points"=>"2", "name"=>"Banana Belt One", "discipline"=>"Road"}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => banana_belt.to_param)

    banana_belt.reload
    assert_nil(banana_belt[:discipline], 'discipline')
  end

  def test_update_discipline_same_as_parent
    banana_belt = standings(:banana_belt)
    assert_equal('Road', banana_belt[:discipline], 'discipline')
    assert_equal('Road', banana_belt.event.discipline, 'Parent event discipline')

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.to_param,
         "standings"=>{"bar_points"=>"2", "name"=>"Banana Belt One", "discipline"=>"Road"}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => banana_belt.to_param)

    banana_belt.reload
    assert_nil(banana_belt[:discipline], 'discipline')
  end  

  def test_update_existing_combined_standings
    event = SingleDayEvent.create!(:discipline => "Mountain Bike")
    standings = event.standings.create!
    
    semi_pro_men = Category.find_or_create_by_name('Semi-Pro Men')
    semi_pro_men_race = standings.races.create!(:category => semi_pro_men, :distance => 40, :laps => 2)
    semi_pro_men_1st_place = semi_pro_men_race.results.create!(:place => 1, :time => 300, 
      :racer => Racer.create!(:name => "semi_pro_men_1st_place"))
    standings.save!
    
    post(:update, "id" => standings.id, 
                  "standings"=>{ "auto_combined_standings"=>"1", 
                                  "name"=>"Portland MTB Short Track Series", 
                                  "bar_points"=>"0", 
                                  "ironman"=>"1", 
                                  "discipline"=>"Mountain Bike"})
    
    assert_nil(flash[:warn], "flash[:warn] should be empty, but was: #{flash[:empty]}")
    assert_response(:redirect)
  end
  
end