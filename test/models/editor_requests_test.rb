# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class EditorRequestsTest < ActiveSupport::TestCase
  test "create" do
    ActionMailer::Base.deliveries.clear
    editor = FactoryBot.create(:person_with_login)
    person = FactoryBot.create(:person_with_login, email: "hotwheels@yahoo.com")
    editor_request = person.editor_requests.create!(editor: editor)
    assert_equal "hotwheels@yahoo.com", editor_request.email, "email"
    assert_equal [editor_request], person.editor_requests, "FactoryBot.create(:person).editor_requests"
    assert_equal [editor_request], editor.sent_editor_requests, "FactoryBot.create(:person).sent_editor_requests"
    assert editor_request.expires_at > Time.zone.now, "Should expire in future"
    assert editor_request.expires_at < 2.weeks.from_now, "Should expire in less than 2 weeks"
    assert_not person.editors.include?(editor), "Should not add promoter as editor of member"
    assert ActionMailer::Base.deliveries.any?, "Should send email to account holder"
  end

  test "validation" do
    editor = FactoryBot.create(:person)
    person = Person.create!
    editor_request = person.editor_requests.create(editor: editor)
    assert editor_request.errors.any?, "should not allow EditorRequest with no email"
  end

  test "grant" do
    editor = FactoryBot.create(:person_with_login)
    person = FactoryBot.create(:person_with_login)
    editor_request = person.editor_requests.create!(editor: editor)
    ActionMailer::Base.deliveries.clear
    editor_request.grant!
    assert ActionMailer::Base.deliveries.any?, "Should send email to account holder"
    assert person.editors.include?(editor), "Should add editor"
  end
end
