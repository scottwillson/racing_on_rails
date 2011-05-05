class PersonMailer < ActionMailer::Base
  def new_login_confirmation(person)
    # Not thread-safe. Won't work for multiple associations.
    ActionMailer::Base.default_url_options[:host] = RacingAssociation.current.rails_host

    @person = person
    
    mail(
      :to => person.email,
      :from => "#{RacingAssociation.current.short_name} Help <#{RacingAssociation.current.email}>",
      :subject => "New #{RacingAssociation.current.short_name} Login"
    )
  end
end
