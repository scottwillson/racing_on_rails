# :stopdoc:
require File.dirname(__FILE__) + '/../../test_helper'

class Admin::RacesControllerTest < ActionController::TestCase
  def setup
    super
    @request.session[:user] = users(:administrator).id
  end

  def test_edit
    kings_valley = events(:kings_valley)
    standings = kings_valley.standings.first
    kings_valley_3 = races(:kings_valley_3)

    get(:edit, :id => kings_valley_3.to_param)
    assert_response(:success)
    assert_template("admin/races/edit")
    assert_not_nil(assigns["race"], "Should assign race")
    assert_equal(kings_valley_3, assigns["race"], "Should assign kings_valley_3 race")
  end
  
  def test_create_result
    race = races(:banana_belt_pro_1_2)
    assert_equal(4, race.results.size, 'Results before insert')
    tonkin_result = results(:tonkin_banana_belt)
    weaver_result = results(:weaver_banana_belt)
    matson_result = results(:matson_banana_belt)
    molly_result = results(:molly_banana_belt)
    assert_equal('1', tonkin_result.place, 'Tonkin place before insert')
    assert_equal('2', weaver_result.place, 'Weaver place before insert')
    assert_equal('3', matson_result.place, 'Matson place before insert')
    assert_equal('16', molly_result.place, 'Molly place before insert')

    post(:create_result, :id => race.id, :before_result_id => weaver_result.id)
    assert_response(:success)
    assert_equal(5, race.results.size, 'Results after insert')
    tonkin_result.reload
    weaver_result.reload
    matson_result.reload
    molly_result.reload
    assert_equal('1', tonkin_result.place, 'Tonkin place after insert')
    assert_equal('3', weaver_result.place, 'Weaver place after insert')
    assert_equal('4', matson_result.place, 'Matson place after insert')
    assert_equal('17', molly_result.place, 'Molly place after insert')

    post(:create_result, :id => race.id, :before_result_id => tonkin_result.id)
    assert_response(:success)
    assert_equal(6, race.results.size, 'Results after insert')
    tonkin_result.reload
    weaver_result.reload
    matson_result.reload
    molly_result.reload
    assert_equal('2', tonkin_result.place, 'Tonkin place after insert')
    assert_equal('4', weaver_result.place, 'Weaver place after insert')
    assert_equal('5', matson_result.place, 'Matson place after insert')
    assert_equal('18', molly_result.place, 'Molly place after insert')

    post(:create_result, :id => race.id, :before_result_id => molly_result.id)
    assert_response(:success)
    assert_equal(7, race.results.size, 'Results after insert')
    tonkin_result.reload
    weaver_result.reload
    matson_result.reload
    molly_result.reload
    assert_equal('2', tonkin_result.place, 'Tonkin place after insert')
    assert_equal('4', weaver_result.place, 'Weaver place after insert')
    assert_equal('5', matson_result.place, 'Matson place after insert')
    assert_equal('19', molly_result.place, 'Molly place after insert')
    
    dnf = race.results.create(:place => 'DNF')
    post(:create_result, :id => race.id, :before_result_id => weaver_result.id)
    assert_response(:success)
    assert_equal(9, race.results(true).size, 'Results after insert')
    tonkin_result.reload
    weaver_result.reload
    matson_result.reload
    molly_result.reload
    dnf.reload
    assert_equal('2', tonkin_result.place, 'Tonkin place after insert')
    assert_equal('5', weaver_result.place, 'Weaver place after insert')
    assert_equal('6', matson_result.place, 'Matson place after insert')
    assert_equal('20', molly_result.place, 'Molly place after insert')
    assert_equal('DNF', dnf.place, 'DNF place after insert')
    
    post(:create_result, :id => race.id, :before_result_id => dnf.id)
    assert_response(:success)
    assert_equal(10, race.results(true).size, 'Results after insert')
    tonkin_result.reload
    weaver_result.reload
    matson_result.reload
    molly_result.reload
    dnf.reload
    assert_equal('2', tonkin_result.place, 'Tonkin place after insert')
    assert_equal('5', weaver_result.place, 'Weaver place after insert')
    assert_equal('6', matson_result.place, 'Matson place after insert')
    assert_equal('20', molly_result.place, 'Molly place after insert')
    assert_equal('DNF', dnf.place, 'DNF place after insert')
    race.results(true).sort!
    assert_equal('DNF', race.results.last.place, 'DNF place after insert')
  end
  
  def test_destroy_result
    result_2 = results(:weaver_banana_belt)
    race = result_2.race
    event = race.standings.event
    assert_not_nil(result_2, 'Result should exist in DB')
    
    post(:destroy_result, :id => race.to_param, :result_id => result_2.to_param)
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'Result should not exist in DB') {Result.find(result_2.id)}
  end
  
  def test_destroy
    kings_valley_women_2003 = races(:kings_valley_women_2003)
    delete(:destroy, :id => kings_valley_women_2003.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'kings_valley_women_2003 should have been destroyed') { Race.find(kings_valley_women_2003.id) }
  end
end