require "test_helper"

class EventsControllerTest < ActionController::TestCase
  def test_index_xml_format
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
    ].each do |key|
      assert_select key
    end
  end
end
