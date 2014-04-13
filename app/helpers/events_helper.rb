module EventsHelper
  # Display email link to promoter. Uses event email if there is one.
  # Displays promoter email in promoter's name is blank.
  # Displays just promoter's name if there are no email addresses.
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

  # FIXME Move to Event?
  def link_to_event_phone(event)
    return event.phone if event.phone.present?
    event.promoter.home_phone if event.promoter && event.promoter.home_phone.present?
  end

  # FIXME move to event?
  # Only show link if flyer approved
  def public_link_to_flyer(event, text = nil)
    return unless event && event.respond_to?(:flyer)
    if event.flyer_approved?
      link_to_flyer event, text
    elsif text.present?
      text
    else
      event.full_name
    end
  end

  # Show link even if not approved
  def link_to_flyer(event, text = nil)
    return unless event

    text = text || event.full_name

    if event.flyer.blank?
      text
    else
      link_to(text, event.flyer).html_safe
    end
  end
end
