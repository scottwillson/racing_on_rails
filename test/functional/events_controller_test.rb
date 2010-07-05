File.expand_path("../../test_helper", __FILE__)

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
    assert_select "a[href=?]", /.*\/admin\/events.*/
  end

  def test_index_as_xml
    get :index, :format => "xml"
    assert_response :success
    assert_equal "application/xml", @response.content_type
    [
      "record > beginner-friendly",
      "record > cancelled",
      "record > city",
      "record > discipline",
      "record > id",
      "record > name",
      "record > parent-id",
      "record > type",
      "record > races",
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
end
