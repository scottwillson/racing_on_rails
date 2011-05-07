require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
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
    
    get :index, :person_id => people(:promoter)
    assert_response :success
    assert_select ".tabs"
    assert_select "a[href=?]", /.*\/admin\/events.*/, :count => 4
  end

  def test_index_as_xml
    get :index, :format => "xml"
    assert_response :success
    assert_equal "application/xml", @response.content_type
    # FIXME Tell AthletesPath that the root element has changed from record to object
    [
      "object > beginner-friendly",
      "object > cancelled",
      "object > city",
      "object > discipline",
      "object > id",
      "object > name",
      "object > parent-id",
      "object > type",
      "object > races",
      "object > date",
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
    get :show, :id => events(:banana_belt_series).id, :format => "xml"
    assert_response :success
  end

  def test_show_as_json
    get :show, :id => events(:banana_belt_series).id, :format => "json"
    assert_response :success
  end
end
