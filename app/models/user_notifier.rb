class UserNotifier < ActionMailer::Base
  def forgot_password(user)
    recipients  user.email_with_name
    from        "#{ASSOCIATION.short_name} <#{ASSOCIATION.email}>"
    subject     "Your password reminder"
    body        :user => user,
                :url => "http://#{STATIC_HOST}/admin/account/login"
  end
end
