require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class BarControllerTest < ActionController::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::CaptureHelper

  def setup
    super
    big_team = Team.create(:name => "T" * 60)
    weaver = people(:weaver)
    weaver.team = big_team
    events(:banana_belt_1).races.first.results.create :person => weaver, :team => big_team
    weaver.first_name = "f" * 60
    weaver.last_name = "T" * 60

    @bar = Bar.calculate! 2004
  end

  def test_index
    get :index
    assert_response :success
    assert_template "bar/index"
  end

  def test_show_no_bar
    get :show, :year => "2012"
    assert_response :success
    assert_template "bar/show"
    assert flash.present?, "flash.present?"
  end
  
  def test_defaults
    get :show, :year => "#{Date.today.year}", :discipline => "overall", :category => "senior_men"
    assert_response :success
    assert_template "bar/show"
  end

  def test_show_empty
    get :show, :year => "#{Date.today.year}", :discipline => "road", :category => "senior_men"
    assert_response :success
    assert_template "bar/show"
  end

  def test_show
    Bar.calculate! Date.today.year
    get :show, :year => "#{Date.today.year}", :discipline => "road", :category => "senior_women"
    assert_response :success
    assert_template "bar/show"
  end
  
  def test_show_age_graded
    weaver = people :weaver
    weaver.date_of_birth = Date.new 1975
    weaver.save!    
    banana_belt = events :banana_belt_1
    banana_belt.date = Date.new 2007, 3, 20
    banana_belt.save!
    masters_men = categories :masters_men
    masters_30_34 = categories :masters_men_30_34
    banana_belt_masters_30_34 = banana_belt.races.create! :category => masters_30_34
    banana_belt_masters_30_34.results.create! :person => weaver, :place => "10"

    Bar.calculate! 2007
    OverallBar.calculate! 2007
    AgeGradedBar.calculate! 2007
    assert_equal OverallBar.find_for_year(2007), AgeGradedBar.find_for_year(2007).parent(true), "AgeGradedBar parent"

    get :show, :discipline => "age_graded", :year => "2007", :category => "masters_men_30_34"
    assert_response :success
    assert_template "bar/show"
    assert_not_nil assigns["race"], "Should assign race"
  end
  
  def test_show_age_graded_redirect_2006
    get :show, :discipline => "age_graded", :year => "2006", :category => "masters_men_30_34"
    assert_redirected_to "http://#{RacingAssociation.current.static_host}/bar/2006/overall_by_age.html"
  end
  
  def test_show_redirect_before_2006
    get :show, :discipline => "overall", :year => "2003", :category => "masters_men_30_34"
    assert_redirected_to "http://#{RacingAssociation.current.static_host}/bar/2003"
  end
  
  def test_categories
    get :categories, :year => "2004"
    assert_response :success
    assert_template "bar/categories"
    assert_not_nil assigns["bar"], "Should assign bar"
    assert_not_nil assigns["excluded_categories"], "Should assign excluded_categories"
  end
  
  def test_bad_discipline
    get :show, :discipline => "badbadbad", :year => "2004", :category => "masters_men_30_34"
    assert_response :success
    assert_template "bar/show"
    assert flash.present?, "flash.present?"
  end
  
  def test_bad_year
    get :show, :discipline => "overall", :year => "19", :category => "masters_men_30_34"
    assert_response :success
    assert_template "bar/show"
    assert flash.present?, "flash.present?"
  end
  
  def test_bad_category
    get :show, :discipline => "overall", :year => "2009", :category => "dhaskjdhal"
    assert_response :success
    assert_template "bar/show"
    assert flash.present?, "flash.present?"
  end
  
  # Lib implementation was broken at one point...
  def test_truncate
    name = "Broadmark"
    truncated = truncate name, :length => 5
    assert_equal "Br...", truncated, "truncated Broadmark"

    truncated = truncate name, :length => 9
    assert_equal "Broadmark", truncated, "truncated Broadmark"

    truncated = truncate name, :length => 8
    assert_equal "Broad...", truncated, "truncated Broadmark"
  end
end
