require 'ostruct'

class MailerWorker < BackgrounDRb::MetaWorker
  set_worker_name :mailer_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def email_members(args)
    logger.info("Emailing #{args[:subject]} to all members")
    Racer.find_all_current_email_addresses.each do |email_address|
      email = Admin::MemberMailer.create_email([email_address])
      logger.debug("create email to #{email_address}")
      email.from = args[:from]
      email.subject = args[:subject]
      email.body = args[:body] || ""
      Admin::MemberMailer.deliver(email)
    end
  end
end
