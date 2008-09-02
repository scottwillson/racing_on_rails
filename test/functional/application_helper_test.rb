require File.dirname(__FILE__) + '/../test_helper'

# :stopdoc:
class ApplicationHelperControllerTest < ActiveSupport::TestCase
  
  include ApplicationHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  
  def setup
    @controller = HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_results_grid
    html = results_grid(races(:kings_valley_pro_1_2))
    assert_not_nil(html)
    expected = %Q{<pre> Pl   Num    Last Name            First Name     Team                                       Points       Time
 16          <a href="/results/racer/#{racers(:tonkin).id}">Tonkin</a>               <a href="/results/racer/#{racers(:tonkin).id}">Erik</a>           Kona                                                        
 17          <a href="/results/racer/#{racers(:weaver).id}">Weaver</a>               <a href="/results/racer/#{racers(:weaver).id}">Ryan</a>                                                                       
</pre>}
    assert_equal(expected, html, 'HTML')
    
    # Sizes set in previous use of column should not affect subsequent callers
    grid_columns('team_name').size = 120
    html = results_grid(races(:kings_valley_pro_1_2))
    assert_equal(expected, html, 'HTML')
  end
  
  def test_div
    assert_equal(nil, div(nil), "nil")
    assert_equal(nil, div(""), "''")
    assert_equal("<div>Text</div>", div("Text"), "Text")
  end
end