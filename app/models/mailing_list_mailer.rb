# frozen_string_literal: true

# Send email to mailing list. Also receives email from Mailman for archives. Old, but battle-tested, code.
class MailingListMailer < ActionMailer::Base
  # Reply just to sender of post, not the whole list
  def private_reply(reply_post, to)
    raise("'To' cannot be blank") if to.blank?
    mail(
      subject: reply_post.subject,
      to: to,
      from: "#{reply_post.from_name} <#{reply_post.from_email}>",
      sent_on: reply_post.date.to_s,
      body: reply_post.body.to_s
    )
  end

  def post(new_post)
    mail(
      subject: new_post.subject,
      to: new_post.mailing_list.name,
      from: "#{new_post.from_name} <#{new_post.from_email}>",
      sent_on: new_post.date.to_s,
      body: new_post.body.to_s
    )
  end

  # Expects raw email from Mailman archiver
  # Really need tricky sender logic for web posts? Shouldn't web
  # posts be forwarded through list, too? If so, update test data
  def receive(email)
    post = Post.new

    # Sometimes we get poorly-encoded data and New Relic chokes
    NewRelic::Agent.disable_all_tracing do
      # Will fail if no matches. Rely on validation
      list_post_header = email["List-Post"]
      matches = list_post_header.to_s.match(/<mailto:(\S+)@/) if list_post_header
      mailing_list_name = if matches
                            matches[1]
                          else
                            email.to.first.to_s
                          end

      mailing_list = MailingList.find_by(name: mailing_list_name.try(:strip))

      unless mailing_list
        email_to = begin
                     email.to.first.to_s
                   rescue StandardError
                     nil
                   end
        email_from = begin
                       email[:from]
                     rescue StandardError
                       nil
                     end
        mail_subject = begin
                         mail.subject
                       rescue StandardError
                         nil
                       end
        Rails.logger.warn "No mailing list for '#{mailing_list_name}' header '#{list_post_header}' to '#{email_to}' from '#{email_from}' about '#{mail_subject}'"
        return true
      end

      post.mailing_list = mailing_list

      post.subject = email.subject

      multipart_related = email.parts.detect { |part| part.mime_type == "multipart/related" }
      multipart_alternative = email.parts.detect { |part| part.mime_type == "multipart/alternative" }
      post.body = if multipart_related
                    # Outlook
                    multipart_related.text_part.try(:decoded)&.gsub("\r", "")
                  elsif multipart_alternative
                    # OS X
                    multipart_alternative.text_part.try(:decoded)
                  else
                    (email.text_part || email.html_part || email.body).try(:decoded)
                  end

      post.body = if post.body
                    post.body.encode("UTF-8", undef: :replace)
                  else
                    ""
                  end

      post.from_name = from_name(email)
      post.from_email = (email[:reply_to] || email[:from]).addresses.first
      post.from_name = post.from_email_obscured if post.from_name.blank?

      post.date = email.date

      Rails.logger.error "Could not save post: #{post.errors.full_messages.join('. ')}" unless Post.save(post, mailing_list)

      ActiveSupport::Notifications.instrument "receive.mailing_list_mailer.racing_on_rails",
                                              mailing_list_id: mailing_list.id,
                                              mailing_list_name: mailing_list.name,
                                              subject: post.subject,
                                              from_email: post.from_email,
                                              from_name: post.from_name

      post
    rescue StandardError => save_error
      Rails.logger.error "Could not save post: #{save_error}"
      begin
        Rails.logger.error email
      rescue StandardError
        Rails.logger.error "Could not save email contents"
      end
      Rails.logger.error post.errors.full_messages if post&.errors.present?
      RacingOnRails::Application.exception_notifier.track_exception save_error
      raise
    end
    post
  end

  private

  def from_name(email)
    if email[:from]&.display_names&.first
      email[:from].display_names.first.split("via").first.strip
    elsif email[:reply_to]
      email[:reply_to].display_names.first
    end
  end
end
