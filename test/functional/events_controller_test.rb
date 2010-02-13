# :stopdoc:
require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_redirected_to schedule_path
  end

  def test_index_with_person_id
    get :index, :person_id => people(:promoter)
    assert_response :success
    assert_select ".tabs", :count => 0
    assert_select "a[href=?]", /.*\/admin\/events.*/, :count => 0
  end
  
  def test_index_with_person_id_promoter
    PersonSession.create(people(:promoter))
    PersonSession.create(people(:promoter))
    
    get :index, :person_id => people(:promoter)
    assert_response :success
    assert_select ".tabs"
    assert_select "a[href=?]", /.*\/admin\/events.*/
  end
end
