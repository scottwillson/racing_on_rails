class EditorRequestMailer < ActionMailer::Base
  def notification(editor_request)
    recipients    "#{editor_request.editor.name} <#{editor_request.editor.email}>"
    from          "#{ASSOCIATION.short_name} Help <#{ASSOCIATION.email}>"
    subject       "#{editor_request.person.name} #{ASSOCIATION.short_name} account access granted"
    body          :editor_request => editor_request, :edit_url => edit_person_url(editor_request.person)
  end
  
  def request(editor_request)
    recipients    "#{editor_request.person.name} <#{editor_request.person.email}>"
    from          "#{ASSOCIATION.short_name} Help <#{ASSOCIATION.email}>"
    subject       "#{editor_request.editor.name} would like access to your #{ASSOCIATION.short_name} account"
    body          :editor_request => editor_request, :edit_url => edit_person_editor_request_url(editor_request.person, editor_request.token)
  end
end
