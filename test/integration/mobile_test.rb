require_relative "racing_on_rails/integration_test"

# :stopdoc:
class MobileTest < RacingOnRails::IntegrationTest
  # In theory, there are 256 combinations, but just test combinations of 2
  test "no mobile" do
    get "/"
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "custom page" do
    Page.create!(slug: "home", body: "<p class='custom'></p>")
    get "/"
    assert_response :success
    assert_select "p.custom"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile page" do
    get "/people"
    assert_response :success
    assert_template "people/index"

    # MBRA has custom template
    if css_select("th.license").empty? && css_select("#people-list").empty?
      flunk "Expected th.license or #people-list"
    end

    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "custom mobile page" do
    Page.create!(slug: "mobile/home", body: "<p class='custom-mobile'></p>")
    get "/"
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "full_site param" do
    get "/", full_site: 1
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table"
    assert cookies["prefer_full_site"].present?, "cookies['prefer_full_site']"
  end

  test "mobile browser" do
    get "/", {}, { "HTTP_USER_AGENT" => "Android" }
    assert_redirected_to "/m/"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile param" do
    get "/", mobile_site: 1
    assert_redirected_to "/m/"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile path" do
    get "/m/"
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "prefer_full_site cookie" do
    cookies["prefer_full_site"] = 1
    get "/"
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table"
    assert cookies["prefer_full_site"].present?, "cookies['prefer_full_site']"
  end

  test "mobile path, mobile browser" do
    get "/m/", {}, { "HTTP_USER_AGENT" => "Android" }
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table", 1
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile path, full_site param" do
    get "/m/", full_site: 1
    assert_redirected_to "http://www.example.com"
    assert cookies["prefer_full_site"].present?, "cookies['prefer_full_site']"
  end

  test "mobile path, mobile param" do
    get "/m/", mobile_site: 1
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table", 1
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile path, custom page" do
    Page.create!(slug: "mobile/home")
    get "/m/"
    assert_response :success
    assert_select "#home_page_results_table", 0
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile path, mobile page" do
    get "/m/people"
    assert_response :success
    assert_template "people/index"
    assert_select "th.license", 0
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile path, prefer_full_site cookie" do
    cookies["prefer_full_site"] = 1
    get "/m/"
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table", 1
    assert cookies["prefer_full_site"].present?, "cookies['prefer_full_site']"
  end

  test "mobile browser, full_site param" do
    get "/", { full_site: 1 }, { "HTTP_USER_AGENT" => "Android" }
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table"
    assert cookies["prefer_full_site"].present?, "cookies['prefer_full_site']"
  end

  test "mobile browser, mobile param" do
    get "/", { mobile_site: 1 }, { "HTTP_USER_AGENT" => "Android" }
    assert_redirected_to "/m/"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile browser, custom page" do
    Page.create!(slug: "home")
    get "/", {}, { "HTTP_USER_AGENT" => "Android" }
    assert_redirected_to "/m/"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile browser, custom mobile page" do
    Page.create!(slug: "mobile/home", body: "<p class='custom-mobile'></p>")
    get "/", {}, { "HTTP_USER_AGENT" => "Android" }
    assert_redirected_to "/m/"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile browser, mobile template" do
    result = FactoryGirl.create(:result)

    get "/events/#{result.event_id}/results", {}, { "HTTP_USER_AGENT" => "Android" }
    assert_redirected_to "/m/events/#{result.event_id}/results"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "prefer_full_site cookie, full_site param" do
    cookies["prefer_full_site"] = 1
    get "/", full_site: 1
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table"
    assert cookies["prefer_full_site"].present?, "cookies['prefer_full_site']"
  end

  test "prefer_full_site cookie, mobile param" do
    cookies["prefer_full_site"] = 1
    get "/", mobile_site: 1
    assert_redirected_to "/m/"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "prefer_full_site cookie, custom page" do
    cookies["prefer_full_site"] = 1
    Page.create!(slug: "home", body: "<p class='custom'></p>")
    get "/"
    assert_response :success
    assert_select "p.custom"
    assert cookies["prefer_full_site"].present?, "cookies['prefer_full_site']"
  end

  test "prefer_full_site cookie, custom mobile page" do
    cookies["prefer_full_site"] = 1
    Page.create!(slug: "mobile/home", body: "<p class='custom-mobile'></p>")
    get "/"
    assert_response :success
    assert_template "home/index"
    assert_select "p.custom-mobile", 0
    assert cookies["prefer_full_site"].present?, "cookies['prefer_full_site']"
  end

  test "full_site param, mobile param" do
    get "/", mobile_site: 1, full_site: 1
    assert_response :success
    assert_template "home/index"
    assert_select "#home_page_results_table"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "full_site param, custom page" do
    Page.create!(slug: "home", body: "<p class='custom'></p>")
    get "/", full_site: 1
    assert_response :success
    assert_select "p.custom"
    assert cookies["prefer_full_site"].present?, "cookies['prefer_full_site']"
  end

  test "full_site param, custom mobile page" do
    cookies["prefer_full_site"] = 1
    Page.create!(slug: "mobile/home", body: "<p class='custom-mobile'></p>")
    get "/"
    assert_response :success
    assert_template "home/index"
    assert_select "p.custom-mobile", 0
    assert cookies["prefer_full_site"].present?, "cookies['prefer_full_site']"
  end

  test "mobile param, custom page" do
    Page.create!(slug: "home", body: "<p class='custom'></p>")
    get "/", mobile_site: 1
    assert_redirected_to "/m/"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "mobile param, custom mobile page" do
    Page.create!(slug: "mobile/home", body: "<p class='custom-mobile'></p>")
    get "/", mobile_site: 1
    assert_redirected_to "/m/"
    assert cookies["prefer_full_site"].blank?, "cookies['prefer_full_site']"
  end

  test "popular pages" do
    result = FactoryGirl.create(:result)

    get "http://example.com/m/"
    assert_response :success

    get "http://example.com/m/schedule"
    assert_response :success

    get "http://example.com/m/results"
    assert_response :success

    mailing_list = FactoryGirl.create(:mailing_list)
    get "http://example.com/m/mailing_lists"
    assert_response :success

    get "http://example.com/m/mailing_lists/#{mailing_list.id}/posts"
    assert_response :success
  end

  test "mailing_list" do
    mailing_list_post = FactoryGirl.create(:post)
    get "http://example.com/m/posts/#{mailing_list_post.id}"
    assert_response :success
  end
end
