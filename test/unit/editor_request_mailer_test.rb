require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EditorRequestMailerTest < ActionMailer::TestCase
  def test_request
    ActionMailer::Base.deliveries.clear
    
    editor = people(:molly)
    person = people(:weaver)
    editor_request = person.editor_requests.new(:editor => editor)
    assert editor_request.valid?, "New request should be valid"
    email = EditorRequestMailer.editor_request(editor_request).deliver
    assert ActionMailer::Base.deliveries.any?

    assert_equal "Ryan Weaver <hotwheels@yahoo.com>", email[:to].to_s, "email to"
    assert_equal "#{editor.name} would like access to your #{RacingAssociation.current.short_name} account", email.subject
    assert email.body.include?(editor_request.token), "Should include EditorRequest token in #{email}"
  end

  def test_notification
    ActionMailer::Base.deliveries.clear
    
    editor = people(:molly)
    editor.email = "molly@example.com"
    editor.save!
    person = people(:weaver)
    editor_request = person.editor_requests.new(:editor => editor)
    assert editor_request.valid?, "New request should be valid"
    email = EditorRequestMailer.notification(editor_request).deliver
    assert ActionMailer::Base.deliveries.any?
    
    assert_equal "Molly Cameron <molly@example.com>", email[:to].to_s
    assert_equal "Ryan Weaver #{RacingAssociation.current.short_name} account access granted", email.subject
  end
end
