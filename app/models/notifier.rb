# Password reset instructions email
class Notifier < ActionMailer::Base
  def password_reset_instructions(people)
    Notifier.default_url_options[:host] = RacingAssociation.current.rails_host
    
    @edit_password_reset_urls = people.map { |person| edit_password_reset_url(person.perishable_token) }    
    @people = people
    
    mail(
      :subject       => "Password Reset Instructions",
      :from          => "#{RacingAssociation.current.short_name} <#{RacingAssociation.current.email}>",
      :recipients    => people.first.email_with_name,
      :sent_on       => Time.zone.now
    )
  end
end
