require File.expand_path("../../test_helper", __FILE__)

class PagesTest < ActionController::IntegrationTest
  def test_render_dynamic_page_from_db
    get("/plain")
    assert_response(:success)
    assert_select("p", :text => "This is a plain page")
  end

  def test_should_find_page_with_html_format
    get("/plain.html")
    assert_response(:success)
    assert_select("p", :text => "This is a plain page")
  end

  def test_render_404_correctly_for_missing_pages
    get("/some_missing_page")
    assert_response(:not_found)
  end
end
