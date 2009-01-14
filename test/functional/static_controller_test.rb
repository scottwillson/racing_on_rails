require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  
  def test_about
    #test a request
    get :about
    assert_response :success
    
    #test the routing
    assert_generates("/static/about", :controller => "static", :action => "about")
  end
  
  def test_join
    #test a request
    get :join
    assert_response :success
    
    #test the routing
    assert_generates("/static/join", :controller => "static", :action => "join")
  end
  
  #I know this will fail, didn't want to pretend to be perfect! RJR
  def test_women_cat4
      #test the routing
    assert_generates("/static/women/cat4", :controller => "static", :action => "women/cat4")
    
    #test a request
    get :women, :type => 'cat4'
    assert_response :success
  end
end
