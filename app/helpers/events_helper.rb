module EventsHelper
  # Display email link to promoter. Uses event email if there is one.
  # Displays promoter email in promoter's name is blank.
  # Displays just promoter's name if there are no email addresses.
  def link_to_event_email(event)
    if event.email.present?
      return mail_to(email)
    end

    promoters.inject([]) do |html, promoter|
      if promoter.email.present?
        html << mail_to(promoter.email, promoter.name)
      else
        html << promoter.name
      end
      html.join(", ")
    end
  end

  def link_to_event_phone(event)
    if event.phone.present?
      return phone
    end

    promoters.inject([]) do |html, promoter|
      if promoter.home_phone.present?
        html << promoter.home_phone
      end
      html.join(", ")
    end
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
    return unless event
    
    if event.flyer.blank?
      event.full_name
    else
      link_to event.full_name, event.flyer
    end
  end
end
