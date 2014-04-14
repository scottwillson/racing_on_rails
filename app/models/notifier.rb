# Password reset instructions email
class Notifier < ActionMailer::Base
  def password_reset_instructions(people)
    @edit_password_reset_urls = people.map { |person| edit_password_reset_url(person.perishable_token, host: RacingAssociation.current.rails_host) }
    @people = people

    mail(
      subject: "Password Reset Instructions",
      from: "#{RacingAssociation.current.short_name} <#{RacingAssociation.current.email}>",
      to: people.first.email_with_name
    )
  end
end
