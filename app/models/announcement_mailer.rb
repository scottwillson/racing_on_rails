class AnnouncementMailer < ActionMailer::Base
  def announcement(recipient)
    subject     'A Candi Vanilla for Candi'
    recipients  recipient
    from       'Yann Blindert <nevens42@yahoo.com>'
  end
end
