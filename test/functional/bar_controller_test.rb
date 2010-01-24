require "test_helper"

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
    events(:banana_belt_1).races.first.results.create(:person => weaver, :team => big_team)
    weaver.first_name = "f" * 60
    weaver.last_name = "T" * 60

    @bar = Bar.calculate!(2004)
  end

  def test_index
    opts = {:controller => "bar", :action => "index"}
    assert_routing("/bar", opts)
    get(:index)
    assert_response(:success)
    assert_template("bar/index")
    assert_not_nil(assigns["year"], "Should  assign year")
    assert_nil(assigns["discipline"], "Should assign not discipline")
    assert_not_nil(assigns["all_disciplines"], "Should assign all_disciplines")
  end

  def test_defaults
    opts = {:controller => "bar", :action => 'show', :year => "#{Date.today.year}", :discipline => 'overall', :category => 'senior_men'}
    assert_routing("/bar/#{Date.today.year}", opts)
    get(:show, :year => "#{Date.today.year}", :discipline => 'overall', :category => 'senior_men')
    assert_response(:success)
    assert_template("bar/show")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_not_nil(assigns["discipline"], "Should assign discipline")
    assert_not_nil(assigns["all_disciplines"], "Should assign all_disciplines")
  end

  def test_show_empty
    opts = {:controller => "bar", :action => 'show', :year => "#{Date.today.year}", :discipline => 'road', :category => 'senior_men'}
    assert_routing("/bar/#{Date.today.year}/road", opts)
    get(:show, :year => "#{Date.today.year}", :discipline => 'road', :category => 'senior_men')
    assert_response(:success)
    assert_template("bar/show")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_not_nil(assigns["discipline"], "Should assign discipline")
    assert_not_nil(assigns["all_disciplines"], "Should assign all_disciplines")
  end

  def test_show
    Bar.calculate!(Date.today.year)
    opts = {:controller => "bar", :action => "show", :year => "#{Date.today.year}", :discipline => "road", :category => 'senior_women'}
    assert_routing("/bar/#{Date.today.year}/road/senior_women", opts)
    get(:show, :year => "#{Date.today.year}", :discipline => "road", :category => 'senior_women')
    assert_response(:success)
    assert_template("bar/show")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_not_nil(assigns["discipline"], "Should assign discipline")
    assert_not_nil(assigns["all_disciplines"], "Should assign all_disciplines")
  end
  
  def test_show_age_graded
    weaver = people(:weaver)
    weaver.date_of_birth = Date.new(1975)
    weaver.save!    
    banana_belt = events(:banana_belt_1)
    banana_belt.date = Date.new(2007, 3, 20)
    banana_belt.save!
    masters_men = categories(:masters_men)
    masters_30_34 = categories(:masters_men_30_34)
    banana_belt_masters_30_34 = banana_belt.races.create!(:category => masters_30_34)
    banana_belt_masters_30_34.results.create!(:person => weaver, :place => '10')

    Bar.calculate!(2007)
    OverallBar.calculate!(2007)
    AgeGradedBar.calculate!(2007)
    opts = {:controller => "bar", :action => 'show', :discipline => "age_graded", :year => "2007", :category => 'masters_men_30_34'}
    assert_routing("/bar/2007/age_graded/masters_men_30_34", opts)
    get(:show, :discipline => "age_graded", :year => "2007", :category => 'masters_men_30_34')
    assert_response(:success)
    assert_template('bar/show')
    assert_not_nil(assigns['race'], 'Should assign race')
    assert_not_nil(assigns['year'], 'Should assign year')
    assert_not_nil(assigns['discipline'], 'Should assign discipline')
    assert_not_nil(assigns['all_disciplines'], 'Should assign all_disciplines')
  end
  
  def test_show_age_graded_redirect_2006
    opts = {:controller => "bar", :action => 'show', :discipline => "age_graded", :year => "2006", :category => 'masters_men_30_34'}
    assert_routing("/bar/2006/age_graded/masters_men_30_34", opts)
    get(:show, :discipline => "age_graded", :year => "2006", :category => 'masters_men_30_34')
    assert_redirected_to("http://#{STATIC_HOST}/bar/2006/overall_by_age.html")
  end
  
  def test_show_redirect_before_2006
    opts = {:controller => "bar", :action => 'show', :discipline => "overall", :year => "2003", :category => 'masters_men_30_34'}
    assert_routing('/bar/2003/overall/masters_men_30_34', opts)
    get(:show, :discipline => 'overall', :year => "2003", :category => 'masters_men_30_34')
    assert_redirected_to("http://#{STATIC_HOST}/bar/2003")
  end
  
  def test_categories
    opts = {:controller => "bar", :action => "categories", :year => "2004"}
    assert_routing("/bar/2004/categories", opts)
    get(:categories, :year => '2004')
    assert_response(:success)
    assert_template("bar/categories")
    assert_not_nil(assigns["bar"], "Should assign bar")
    assert_not_nil(assigns["excluded_categories"], "Should assign excluded_categories")
  end
  
  def test_bad_discipline
    get(:show, :discipline => "badbadbad", :year => "2004", :category => 'masters_men_30_34')
    assert_response(:success)
    assert_template('bar/not_found')
    assert(!flash.empty?, 'flash.empty?')
  end
  
  def test_bad_year
    get(:show, :discipline => "overall", :year => "19", :category => 'masters_men_30_34')
    assert_response(:success)
    assert_template('bar/not_found')
    assert(!flash.empty?, 'flash.empty?')
  end
  
  def test_bad_category
    get(:show, :discipline => 'overall', :year => "2009", :category => 'dhaskjdhal')
    assert_response(:success)
    assert_template('bar/not_found')
    assert(!flash.empty?, 'flash.empty?')
  end
  
  # Lib implementation was broken at one point...
  def test_truncate
    name = 'Broadmark'
    truncated = truncate(name, :length => 5)
    assert_equal('Br...', truncated, 'truncated Broadmark')

    truncated = truncate(name, :length => 9)
    assert_equal('Broadmark', truncated, 'truncated Broadmark')

    truncated = truncate(name, :length => 8)
    assert_equal('Broad...', truncated, 'truncated Broadmark')
  end
end
