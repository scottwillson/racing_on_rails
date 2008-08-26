module TeamsHelper
  def link_to_contact(team)
    if !team.contact_email.blank?
      mail_to(team.contact_email, team.contact_name)
    else
      team.contact_name
    end
  end
end