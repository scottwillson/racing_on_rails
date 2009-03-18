require "test_helper"

class UserNotifierTest < ActionMailer::TestCase
  tests UserNotifier
  fixtures :users
  
  def test_forgot_password
    user = User.find_by_email(users(:administrator).email)
    UserNotifier.deliver_forgot_password(user)
    assert !ActionMailer::Base.deliveries.empty?
    
    sent = ActionMailer::Base.deliveries.first
    assert_equal [user.email], sent.to
    assert_equal ["#{ASSOCIATION.email}"], sent.from
    assert_equal "Your password reminder", sent.subject
  end
end
