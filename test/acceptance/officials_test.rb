require "acceptance/webdriver_test_case"

class OfficialsTest < WebDriverTestCase
  def test_view_assignments
    open "/admin/first_aid_providers"
    assert_current_url(/\/person_session\/new/)
    
    login_as :administrator
    member = people(:member)
    open "/admin/people/#{member.id}/edit"
    check "person_official"
    click "save"
    
    logout
    login_as :member
    open "/admin/first_aid_providers"
    assert_current_url(/\/admin\/first_aid_providers/)
  end
end
