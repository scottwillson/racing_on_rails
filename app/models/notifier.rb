class Notifier < ActionMailer::Base

  def password_reset_instructions(person)
    Notifier.default_url_options[:host] = RAILS_HOST
    
    subject       "Password Reset Instructions"
    from          "#{ASSOCIATION.short_name} <#{ASSOCIATION.email}>"
    recipients    person.email_with_name
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(person.perishable_token), :person => person
  end
end
