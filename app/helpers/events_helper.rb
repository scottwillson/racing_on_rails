# Display email link to promoter. Uses event email if there is one.
# Displays promoter email in promoter's name is blank.
# Displays just promoter's name if there are no email addresses.
module EventsHelper
  def link_to_event_email(event)
    email = event.email if event.email.present?
    email = event.promoter.email if !email && event.promoter && event.promoter.email.present?
    
    name = event.promoter.name if event.promoter && event.promoter.name.present?
    name = email if name.nil?

    if email.present?
      mail_to email, name
    else
      name
    end
  end

  def link_to_event_phone(event)
    return event.phone if event.phone.present?
    event.promoter.home_phone if event.promoter && event.promoter.home_phone.present?
  end

  # Only show link if flyer approved
  def public_link_to_flyer(event)
    if event && event.flyer_approved?
      link_to_flyer event
    end
  end
end
