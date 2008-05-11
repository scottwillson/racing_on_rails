class Admin::MemberMailer < ActionMailer::Base

  def email(members = [])
    recipients members
    body ""
  end
end
