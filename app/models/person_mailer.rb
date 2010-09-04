class PersonMailer < ActionMailer::Base
  def new_login_confirmation(person)
    recipients    person.email
    from          "#{RacingAssociation.current.short_name} Help <#{RacingAssociation.current.email}>"
    subject       "New #{RacingAssociation.current.short_name} Login"
    sent_on       Time.zone.now
    body          :person => person
  end
end
