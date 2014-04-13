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
    assert_select ".nav.tabs", :count => 0
    assert_select "a[href=?]", /.*\/admin\/events.*/, :count => 0
  end

  def test_index_with_person_id_promoter
    Timecop.freeze(Time.zone.local(2012)) do
      promoter = FactoryGirl.create(:promoter)
      PersonSession.create(promoter)

      use_ssl
      get :index, :person_id => promoter
      assert_response :success
      if css_select(".nav.tabs").present?
        assert_select "a[href=?]", /.*\/admin\/events.*/
      end
    end
  end

  def test_index_as_xml
    Timecop.freeze(Time.zone.local(2012, 5)) do
      FactoryGirl.create(:event)
      get :index, :format => "xml"
      assert_response :success
      assert_equal "application/xml", @response.content_type
      [
        "single-day-event > id",
        "single-day-event > name",
        "single-day-event > date"
      ].each { |key| assert_select key }
    end
  end
end
