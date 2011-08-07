require "acceptance/webdriver_test_case"

# :stopdoc:
class OfficialsTest < WebDriverTestCase
  def test_view_assignments
    open "/admin/first_aid_providers"
    assert_current_url %r{/person_session/new}

    open "/people"
    assert_no_element "export_link"
    
    login_as :administrator
    member = people(:member)
    open "/admin/people/#{member.id}/edit"
    check "person_official"
    click "save"
    
    logout
    login_as :member
    open "/admin/first_aid_providers"
    assert_current_url %r{/admin/first_aid_providers}

    open "/people"
    remove_download "scoring_sheet.xls"
    click "export_link"
    wait_for_not_current_url(/\/admin\/people.xls\?excel_layout=scoring_sheet&include=members_only/)
    wait_for_download "scoring_sheet.xls"
    assert_no_errors
  end
end
