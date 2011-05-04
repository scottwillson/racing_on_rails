# Send email to mailing list. Also receives email from Mailman for archives. Old, but battle-tested, code.
class MailingListMailer < ActionMailer::Base

  # Reply just to sender of post, not the whole list
  def private_reply(reply_post, to)
    # Not thread-safe. Won't work for multiple associations.
    ActionMailer::Base.default_url_options[:host] = RacingAssociation.current.rails_host
    
    raise("'To' cannot be blank") if to.blank?
    mail(
      :subject => reply_post.subject,
      :to => to,
      :from => reply_post.sender,
      :sent_on => reply_post.date.to_s,
      :body => reply_post.body.to_s
    )
  end

  def post(new_post)
    # Not thread-safe. Won't work for multiple associations.
    ActionMailer::Base.default_url_options[:host] = RacingAssociation.current.rails_host
    mail(
      :subject => new_post.subject,
      :to => new_post.mailing_list.name,
      :from => new_post.sender,
      :sent_on => new_post.date.to_s,
      :body => new_post.body.to_s
    )
  end

  # Expects raw email from Mailman archiver
  # Really need tricky sender logic for web posts? Shouldn't web
  # posts be forwarded through list, too? If so, update test data
  def receive(email)
    post = Post.new

    # Will fail if no matches. Rely on validation
    list_post_header = email["List-Post"]
    matches = list_post_header.to_s.match(/<mailto:(\S+)@/) if list_post_header
    if matches
      mailing_list_name = matches[1]
    else
      mailing_list_name = email.to.first.to_s
    end
    post.mailing_list = MailingList.find_by_name(mailing_list_name)

    post.subject = email.subject
    post.body = email.body.decoded
    post.from_name = email[:from].display_names.first || email[:from].addresses.first
    post.from_email_address = email[:from].addresses.first
    post.date = email.date
    
    begin
      post.save!
    rescue => save_error
      Rails.logger.error("Could not save post: #{save_error}")
      if post && post.errors.any?
        Rails.logger.error(post.errors.full_messages)
      end
      raise
    end
    post
  end
end
