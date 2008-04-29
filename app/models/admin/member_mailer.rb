class Admin::MemberMailer < ActionMailer::Base

  def email(sent_at = Time.now)
    @subject    = 'Admin::MemberMailer#email'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end
end
