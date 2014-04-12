require_relative "racing_on_rails/integration_test"

# :stopdoc:
class PagesTest < RacingOnRails::IntegrationTest
  def test_render_dynamic_page_from_db
    FactoryGirl.create(:page)
    get "/plain"
    assert_response :success
    assert_select "p", :text => "This is a plain page"
  end

  def test_should_find_page_with_html_format
    FactoryGirl.create(:page)
    get "/plain.html"
    assert_response :success
    assert_select "p", :text => "This is a plain page"
  end

  def test_render_404_correctly_for_missing_pages
    FactoryGirl.create(:page)
    assert_raise(ActionController::RoutingError) { get "/some_missing_page" }
  end
end
