require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class HomeControllerTest < ActionController::TestCase
  def test_index
    FactoryGirl.create(:event, :date => 1.day.from_now)
    future_national_federation_event = FactoryGirl.create(:event, :sanctioned_by => "USAC")
    get(:index)
    assert_not_nil(assigns['upcoming_events'], 'Should assign upcoming_events')
    assert_not_nil(assigns['recent_results'], 'Should assign recent_results')
    
    assert(!assigns["recent_results"].include?(future_national_federation_event), "Should only include association-sanctioned events")
  end
end
