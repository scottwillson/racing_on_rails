# Send email to mailing list. Also receives email from Mailman for archives. Old, but battle-tested, code.
class MailingListMailer < ActionMailer::Base

  # Reply just to sender of post, not the whole list
  def private_reply(post, to)
    # Not thread-safe. Won't work for multiple associations.
    ActionMailer::Base.default_url_options[:host] = RacingAssociation.current.rails_host
    
    raise("'To' cannot be blank") if to.blank?
    @subject    = post.subject
    @body       = post.body
    @recipients = to
    @from       = post.sender
    @sent_on    = post.date
    @headers    = {}
  end

  def post(post)
    # Not thread-safe. Won't work for multiple associations.
    ActionMailer::Base.default_url_options[:host] = RacingAssociation.current.rails_host
    
    @subject    = post.subject
    @body       = post.body
    @recipients = post.mailing_list.name
    @from       = post.sender
    @sent_on    = post.date
    @headers    = {}
  end

  # Expects raw email from Mailman archiver
  # Really need tricky sender logic for web posts? Shouldn't web
  # posts be forwarded through list, too? If so, update test data
  def receive(email)
    post = Post.new

    # Will fail if no matches. Rely on validation
    list_post_header = email.header_string("List-Post")
    matches = list_post_header.match(/<mailto:(\S+)@/) if list_post_header
    if matches
      mailing_list_name = matches[1]
    else
      mailing_list_name = email.to.first.to_s
    end
    post.mailing_list = MailingList.find_by_name(mailing_list_name)

    post.subject = email.subject
    
    if email.multipart?
      plain_text_part = nil

      # Outlook
      related_part = email.parts.find { |part| 
        part.content_type == "multipart/related"
      }
      if related_part
        alt_part = related_part.parts.find { |part| 
          part.content_type == "multipart/alternative"
        }
      else
        alt_part = email.parts.find { |part| 
          part.content_type == "multipart/alternative"
        }
      end
      
      # OS X rich text email
      if alt_part 
        plain_text_part = alt_part.parts.find { |part| 
          part.content_type == "text/plain"
        }
      end

      plain_text_part = email.parts.find { |part| 
        part.content_type == "text/plain"
      } unless plain_text_part
      
      plain_text_part = email.parts.find { |part| 
        part.content_type == "text/html"
      } unless plain_text_part
      
      post.body = plain_text_part.body
    end
    
    if post.body.blank?
      post.body = email.body
    end
    
    post.from_name = email.friendly_from
    post.from_email_address = email.from.first
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
