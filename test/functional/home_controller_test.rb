require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class HomeControllerTest < ActionController::TestCase
  def test_index
    get(:index)
    assert_not_nil(assigns['upcoming_events'], 'Should assign upcoming_events')
    assert_not_nil(assigns['recent_results'], 'Should assign recent_results')
    
    assert(!assigns["recent_results"].include?(events(:future_national_federation_event)), "Should only include association-sanctioned events")
    assert(!assigns["recent_results"].include?(events(:usa_cycling_event_with_results)), "Should only include association-sanctioned events")
  end
end
