require_relative "../test_helper"

# :stopdoc:
class EditorRequestMailerTest < ActionMailer::TestCase
  test "request" do
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      editor = FactoryGirl.create(:person, email: "molly@example.com", name: "Molly Cameron")
      person = FactoryGirl.create(:person, email: "hotwheels@yahoo.com", name: "Ryan Weaver")
      editor_request = person.editor_requests.new(editor: editor)
      assert editor_request.valid?, "New request should be valid, but #{editor_request.errors.full_messages.join(", ")}"
      email = EditorRequestMailer.editor_request(editor_request).deliver_now

      assert_equal "Ryan Weaver <hotwheels@yahoo.com>", email[:to].to_s, "email to"
      assert_equal "#{editor.name} would like access to your #{RacingAssociation.current.short_name} account", email.subject
      assert email.body.include?(editor_request.token), "Should include EditorRequest token in #{email}"
    end
  end

  test "notification" do
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      editor = FactoryGirl.create(:person, email: "molly@example.com", name: "Molly Cameron")
      person = FactoryGirl.create(:person, email: "hotwheels@yahoo.com", name: "Ryan Weaver")
      editor_request = person.editor_requests.new(editor: editor)
      assert editor_request.valid?, "New request should be valid, but #{editor_request.errors.full_messages.join(", ")}"
      email = EditorRequestMailer.notification(editor_request).deliver_now

      assert_equal "Molly Cameron <molly@example.com>", email[:to].to_s
      assert_equal "Ryan Weaver #{RacingAssociation.current.short_name} account access granted", email.subject
    end
  end
end
