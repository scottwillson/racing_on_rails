class PersonMailer < ActionMailer::Base
  def new_login_confirmation(person)
    @person = person
    
    mail(
      :to => person.email,
      :from => "#{RacingAssociation.current.short_name} Help <#{RacingAssociation.current.email}>",
      :subject => "New #{RacingAssociation.current.short_name} Login"
    )
  end
end
