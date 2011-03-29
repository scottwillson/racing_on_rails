class EditorRequestMailer < ActionMailer::Base
  def notification(editor_request)
    # Not thread-safe. Won't work for multiple associations.
    ActionMailer::Base.default_url_options[:host] = RacingAssociation.current.rails_host
    
    @editor_request = editor_request
    @edit_url = edit_person_url(editor_request.person)

    mail(
      :to => "#{editor_request.editor.name} <#{editor_request.editor.email}>",
      :from => "#{RacingAssociation.current.short_name} Help <#{RacingAssociation.current.email}>",
      :subject => "#{editor_request.person.name} #{RacingAssociation.current.short_name} account access granted"
    )
  end
  
  def editor_request(editor_request)
    # Not thread-safe. Won't work for multiple associations.
    ActionMailer::Base.default_url_options[:host] = RacingAssociation.current.rails_host
    
    @editor_request = editor_request
    @edit_url = edit_person_editor_request_url(editor_request.person, editor_request.token)

    mail(
      :to => "#{editor_request.person.name} <#{editor_request.person.email}>",
      :from => "#{RacingAssociation.current.short_name} Help <#{RacingAssociation.current.email}>",
      :subject => "#{editor_request.editor.name} would like access to your #{RacingAssociation.current.short_name} account"
    )
  end
end
