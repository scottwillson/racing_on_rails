require File.dirname(__FILE__) + '/../test_helper'

# :stopdoc:
class TeamsHelperTest < ActiveSupport::TestCase
  
  include TeamsHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  
  def setup
    @controller = TeamsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_blank_link_to_contact
    get(:index)
    team = Team.new
    assert_equal(nil, link_to_contact(team), "blank contact name")
  end

  def test_name_only_link_to_contact
    get(:index)
    team = Team.new(:contact_name => "Davis Phinney")
    assert_equal("Davis Phinney", link_to_contact(team), "contact name only")
  end

  def test_name_and_email_link_to_contact
    get(:index)
    team = Team.new(:contact_name => "Davis Phinney", :contact_email => "david@team.com")
    assert_equal(%Q{<a href="mailto:david@team.com">Davis Phinney</a>}, link_to_contact(team), "contact name and email")
  end

  def test_email_only_link_to_contact
    get(:index)
    team = Team.new(:contact_email => "david@team.com")
    assert_equal(%Q{<a href="mailto:david@team.com">david@team.com</a>}, link_to_contact(team), "contact email only")
  end
end