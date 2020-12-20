# frozen_string_literal: true

require_relative "racing_on_rails/integration_test"

# :stopdoc:
class PagesTest < RacingOnRails::IntegrationTest
  test "render dynamic page from db" do
    FactoryBot.create(:page)
    get "/plain"
    assert_response :success
    assert_select "p", text: "This is a plain page"
  end

  test "should find page with html format" do
    FactoryBot.create(:page)
    get "/plain.html"
    assert_response :success
    assert_select "p", text: "This is a plain page"
  end

  test "render 404 correctly for missing pages" do
    FactoryBot.create(:page)
    assert_raise(ActionController::RoutingError) { get "/some_missing_page" }
  end
end
