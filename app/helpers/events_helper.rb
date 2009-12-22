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
    return unless event && event.respond_to?(:flyer)
    if event.flyer_approved?
      link_to_flyer event
    else
      event.full_name
    end
  end

  # Show link even if not approved
  def link_to_flyer(event)
    # TODO Add more options and use throughout
    return unless event
    
    if event.flyer.blank?
      event.full_name
    else
      link_to event.full_name, event.flyer
    end
  end
end
