require "test_helper"

class EditorRequestMailerTest < ActionMailer::TestCase
  def test_request
    ActionMailer::Base.deliveries.clear
    
    editor = people(:molly)
    person = people(:weaver)
    editor_request = person.editor_requests.new(:editor => editor)
    assert editor_request.valid?, "New request should be valid"
    email = EditorRequestMailer.deliver_request(editor_request)
    assert ActionMailer::Base.deliveries.any?

    assert_equal [ "Ryan Weaver" ], email.to_addrs.map(&:name)
    assert_equal [ "hotwheels@yahoo.com" ], email.to_addrs.map(&:address)
    assert_equal "#{editor.name} would like access to your #{ASSOCIATION.short_name} account", email.subject
    assert_match(editor_request.token, email.body)
  end

  def test_notification
    ActionMailer::Base.deliveries.clear
    
    editor = people(:molly)
    editor.email = "molly@example.com"
    editor.save!
    person = people(:weaver)
    editor_request = person.editor_requests.new(:editor => editor)
    assert editor_request.valid?, "New request should be valid"
    email = EditorRequestMailer.deliver_notification(editor_request)
    assert ActionMailer::Base.deliveries.any?

    assert_equal [ "Molly Cameron" ], email.to_addrs.map(&:name)
    assert_equal [ "molly@example.com" ], email.to_addrs.map(&:address)
    assert_equal "Ryan Weaver #{ASSOCIATION.short_name} account access granted", email.subject
  end
end
