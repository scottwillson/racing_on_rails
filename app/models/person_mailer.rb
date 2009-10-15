class PersonMailer < ActionMailer::Base
  def new_login_confirmation(person)
    recipients    person.email
    from          "#{ASSOCIATION.short_name} Help <#{ASSOCIATION.email}>"
    subject       "New #{ASSOCIATION.short_name} Login"
    sent_on       Time.now
    body          :person => person
  end
end
