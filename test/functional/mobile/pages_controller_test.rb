require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class PagesControllerTest < ActionController::TestCase
  def test_not_choose_mobile_template
    @request.host = "m.cbra.org"
    FactoryGirl.create(:page, :body => "Not a mobile page", :title => "Results")
    assert_raise ActiveRecord::RecordNotFound do
      get :show, :path => "/results"
    end
  end
end
