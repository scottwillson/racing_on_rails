require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class MobileTest < ActionController::IntegrationTest
  def test_popular_pages
    result = FactoryGirl.create(:result)

    get "http://m.cbra.org/"
    assert_response :success
    
    get "http://m.cbra.org/events/#{result.event_id}/races"
    assert_response :success

    get "http://m.cbra.org/schedule"
    assert_response :success

    get "http://m.cbra.org/results"
    assert_response :success

    mailing_list = FactoryGirl.create(:mailing_list)
    get "http://m.cbra.org/mailing_lists"
    assert_response :success
    
    get "http://m.cbra.org/mailing_lists/#{mailing_list.id}/posts"
    assert_response :success

    mailing_list_post = FactoryGirl.create(:post)
    get "http://m.cbra.org/posts/#{mailing_list_post.id}"
    assert_response :success
  end

  def test_categories_page_redirect
    category = FactoryGirl.create(:category)

    get "http://m.cbra.org/categories/#{category.id}/races", { :mobile_site => 1 }, { "HTTP_USER_AGENT" => "Android" }
    assert_redirected_to "http://cbra.org/categories/#{category.id}/races?"

    get "http://cbra.org/categories/#{category.id}/races?", {}, { "HTTP_USER_AGENT" => "Android" }
    assert_response :success
  end
end
