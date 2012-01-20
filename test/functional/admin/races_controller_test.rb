require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::RacesControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end

  def test_edit
    kings_valley_3 = FactoryGirl.create(:race)
    get(:edit, :id => kings_valley_3.to_param)
    assert_response(:success)
    assert_template("admin/races/edit")
    assert_not_nil(assigns["race"], "Should assign race")
    assert_equal(kings_valley_3, assigns["race"], "Should assign kings_valley_3 race")
  end
  
  def test_edit_own_race
    race = FactoryGirl.create(:race)
    login_as race.promoter
    get :edit, :id => race.to_param
    assert_response :success
    assert_template "admin/races/edit"
    assert_not_nil assigns["race"], "Should assign race"
  end
  
  def test_cannot_edit_someone_elses_race
    race = FactoryGirl.create(:race)
    login_as FactoryGirl.create(:person)
    get :edit, :id => race.to_param
    assert_redirected_to unauthorized_path
  end
  
  def test_update
    race = FactoryGirl.create(:race)
    put :update, :id => race.to_param, :race => { :category_name => "Open", :event_id => race.event.to_param }
    assert_redirected_to edit_admin_race_path(race)
  end

  def test_create_result
    race = FactoryGirl.create(:race)
    tonkin_result = FactoryGirl.create(:result, :race => race, :place => "1")
    weaver_result = FactoryGirl.create(:result, :race => race, :place => "2")
    matson_result = FactoryGirl.create(:result, :race => race, :place => "3")
    molly_result = FactoryGirl.create(:result, :race => race, :place => "16")

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
    
    post :create_result, :id => race.id
    assert_response(:success)
    assert_equal(11, race.results(true).size, 'Results after insert')
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
    result_2 = FactoryGirl.create(:result)
    race = result_2.race
    assert_not_nil(result_2, 'Result should exist in DB')
    
    post(:destroy_result, :id => race.to_param, :result_id => result_2.to_param)
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'Result should not exist in DB') {Result.find(result_2.id)}
  end
  
  def test_destroy
    kings_valley_women_2003 = FactoryGirl.create(:race)
    delete(:destroy, :id => kings_valley_women_2003.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'kings_valley_women_2003 should have been destroyed') { Race.find(kings_valley_women_2003.id) }
  end
  
  def test_new
    event = FactoryGirl.create(:event)
    get :new, :event_id => event.to_param
    assert_response :success
    assert_not_nil assigns(:race), "@race"
    assert_template :edit
  end
  
  def test_new_as_promoter
    event = FactoryGirl.create(:event)
    login_as event.promoter
    get :new, :event_id => event.to_param
    assert_response :success
    assert_not_nil assigns(:race), "@race"
    assert_template :edit
  end
  
  def test_create
    event = FactoryGirl.create(:event)
    assert event.races.none? { |race| race.category_name == "Senior Women" }
    post :create, :race => { :category_name => "Senior Women", :event_id => event.to_param }
    assert_not_nil assigns(:race), "@race"
    assert_redirected_to edit_admin_race_path assigns(:race)
    assert event.races(true).any? { |race| race.category_name == "Senior Women" }
  end
  
  def test_invalid_create
    event = FactoryGirl.create(:event)
    assert event.races.none? { |race| race.category_name == "Senior Women" }
    post :create, :race => { :category_name => "", :event_id => event.to_param }
    assert_not_nil assigns(:race), "@race"
    assert_response :success
    assert event.races.none? { |race| race.category_name == "Senior Women" }
  end

  def test_create_xhr
    event = FactoryGirl.create(:event)
    xhr :post, :create, :event_id => event.to_param
    assert_response :success
    assert_not_nil assigns(:race), "@race"
    assert_equal "New Category", assigns(:race).name, "@race name"
    assert !assigns(:race).new_record?, "@race should be created"
    assert_template "admin/races/create", "template"
  end

  def test_create_xhr_promoter
    event = FactoryGirl.create(:event)
    login_as event.promoter
    xhr :post, :create, :event_id => event.to_param
    assert_response :success
    assert_not_nil assigns(:race), "@race"
    assert_equal "New Category", assigns(:race).name, "@race name"
    assert !assigns(:race).new_record?, "@race should be created"
    assert_template "admin/races/create", "template"
  end
  
  def test_admin_set_race_category_name
    race = FactoryGirl.create(:race)
    xhr :put, :update_attribute, :id => race.to_param, :value => "Fixed Gear", :name => "category_name"
    assert_response :success
    assert_not_nil assigns(:race), "@race"
    assert_equal "Fixed Gear", assigns(:race).reload.category_name, "Should update category"
  end
  
  def test_promoter_set_race_category_name
    race = FactoryGirl.create(:race)
    login_as race.promoter
    xhr :put, :update_attribute, :id => race.to_param, :value => "Fixed Gear", :name => "category_name"
    assert_response :success
    assert_not_nil assigns(:race), "@race"
    assert_equal "Fixed Gear", assigns(:race).reload.category_name, "Should update category"
  end
  
  def test_propagate
    event = FactoryGirl.create(:event)
    login_as event.promoter
    xhr :post, :propagate, :event_id => event.to_param
    assert_response :success
    assert_template "admin/races/propagate", "template"
  end
end
