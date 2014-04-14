require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class TeamsHelperTest < ActionController::TestCase

  tests TeamsController

  include TeamsHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper

  test "blank link to contact" do
    get(:index)
    team = Team.new
    assert_equal(nil, link_to_contact(team), "blank contact name")
  end

  test "name only link to contact" do
    get(:index)
    team = Team.new(contact_name: "Davis Phinney")
    assert_equal("Davis Phinney", link_to_contact(team), "contact name only")
  end

  test "name and email link to contact" do
    get(:index)
    team = Team.new(contact_name: "Davis Phinney", contact_email: "david@team.com")
    assert_equal(%Q{<a href="mailto:david@team.com">Davis Phinney</a>}, link_to_contact(team), "contact name and email")
  end

  test "email only link to contact" do
    get(:index)
    team = Team.new(contact_email: "david@team.com")
    assert_equal(%Q{<a href="mailto:david@team.com">david@team.com</a>}, link_to_contact(team), "contact email only")
  end
end
