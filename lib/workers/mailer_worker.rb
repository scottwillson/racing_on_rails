require 'ostruct'

class MailerWorker < BackgrounDRb::MetaWorker
  set_worker_name :mailer_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def email_members(args)
    logger.info("Emailing #{args[:subject]} to all members")    
    # recipients = Racer.find_all_current_email_addresses
    recipients = Racer.find(:all, :conditions => ["email is not null and email != ''"]).map do |racer|
      racer.email.gsub(/@.*$/, "@butlerpress.com")
    end
    email = Admin::MemberMailer.create_email(recipients)
    logger.debug("create email")
    email.from = args[:from]
    email.subject = args[:subject]
    email.body = args[:body] || ""
    Admin::MemberMailer.deliver(email)
    logger.debug("delivered")
  end
end
