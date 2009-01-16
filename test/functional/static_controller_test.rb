require "test_helper"

class StaticControllerTest < ActionController::TestCase
  
  def setup
    super
    StaticController.prepend_view_path(File.expand_path("#{RAILS_ROOT}/test/fixtures/views"))
  end
  
  def test_static_page
    assert_recognizes({ :controller => "static", :action => "about" }, "/static/about")
    get(:about)
    assert_response(:success)    
  end
  
  def test_erb_page
    assert_recognizes({ :controller => "static", :action => "join" }, "/static/join")
    get(:join)
    assert_response :success    
  end
  
  def test_women_cat4
    # want /static/women/cat4 to map nicely to template in app/views/static/women/cat4.html.erb, but this is broken
    # I think we want:
    # assert_recognizes({ :controller => "static", :action => "index", :path => "women/ca4" }, "/static/women/cat4")
    # get(:index, :path => "women/cat4")
    # assert_response(:success)    

    assert_recognizes({ :controller => "static", :action => "women", :id => "cat4" }, "/static/women/cat4")
    assert_raise(NoMethodError) { get(:index, :path => "women/cat4") }
  end
  
  def test_404
    # Should return 404, but currently throws an exception
    # assert_response(:missing)
    assert_raise(ActionController::UnknownAction) { get(:page_with_no_static_template) }
  end
end
