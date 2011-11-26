require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EventsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_redirected_to schedule_path
  end

  def test_index_with_person_id
    promoter = FactoryGirl.create(:promoter)
    get :index, :person_id => promoter
    assert_response :success
    assert_select ".tabs", :count => 0
    assert_select "a[href=?]", /.*\/admin\/events.*/, :count => 0
  end
  
  def test_index_with_person_id_promoter
    promoter = FactoryGirl.create(:promoter)
    PersonSession.create(promoter)
    
    get :index, :person_id => promoter
    assert_response :success
    assert_select ".tabs"
    assert_select "a[href=?]", /.*\/admin\/events.*/
  end

  def test_index_as_xml
    FactoryGirl.create(:race)
    get :index, :format => "xml"
    assert_response :success
    assert_equal "application/xml", @response.content_type
    [
      "single-day-event > beginner-friendly",
      "single-day-event > cancelled",
      "single-day-event > city",
      "single-day-event > discipline",
      "single-day-event > id",
      "single-day-event > name",
      "single-day-event > parent-id",
      "single-day-event > type",
      "single-day-event > races",
      "single-day-event > date",
      "races > race",
      "race > city",
      "race > distance",
      "race > field-size",
      "race > finishers",
      "race > id",
      "race > laps",
      "race > notes",
      "race > state",
      "race > time",
      "race > category",
      "category > ages-begin",
      "category > ages-end",
      "category > friendly-param",
      "category > id",
      "category > name"
    ].each { |key| assert_select key }
  end

  def test_show_as_xml
    banana_belt_series = FactoryGirl.create(:event)
    get :show, :id => banana_belt_series.id, :format => "xml"
    assert_response :success
  end

  def test_show_as_json
    banana_belt_series = FactoryGirl.create(:event)
    get :show, :id => banana_belt_series.id, :format => "json"
    assert_response :success
  end
end
