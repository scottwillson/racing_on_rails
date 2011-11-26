require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::RaceNumbersControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end
  
  def test_new
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline)
    person = FactoryGirl.create(:person)
    xhr :get, :new, :person_id => person.to_param
    assert_response :success
  end

  def test_destroy
    race_number = FactoryGirl.create(:race_number)
    assert_not_nil(RaceNumber.find(race_number.id), 'RaceNumber should exist')

    xhr :delete, :destroy, :id => race_number.to_param
    assert_response :success
    
    assert_raise(ActiveRecord::RecordNotFound, "Should delete RaceNumber") {RaceNumber.find(race_number.id)}
  end
end