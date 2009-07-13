require "test_helper"

# For now, only test for some 404s found in production
class PublicPagesTest < ActionController::IntegrationTest
  def test_popular_pages
    get "/events/"
    assert_redirected_to schedule_url
  end
end
