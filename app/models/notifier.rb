# Password reset instructions email
class Notifier < ActionMailer::Base
  def password_reset_instructions(people)
    Notifier.default_url_options[:host] = RAILS_HOST
    
    subject       "Password Reset Instructions"
    from          "#{ASSOCIATION.short_name} <#{ASSOCIATION.email}>"
    recipients    people.first.email_with_name
    sent_on       Time.zone.now
    body          :edit_password_reset_urls => people.map { |person| edit_password_reset_url(person.perishable_token) }, :people => people
  end
end
