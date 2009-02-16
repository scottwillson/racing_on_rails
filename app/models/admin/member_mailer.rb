class Admin::MemberMailer < ActionMailer::Base

  def email(members = [])
    recipients members
    body ""
  end
  
  def self.email_all(subject, from, body)
	logger.info("Emailing #{subject} to all members")
	Racer.find_all_current_email_addresses.each do |email_address|
	  email = Admin::MemberMailer.create_email([email_address])
	  logger.debug("create email to #{email_address}")
	  email.from = from
	  email.subject = subject
	  email.body = body || ""
	  Admin::MemberMailer.deliver(email)
	end
  end
end
