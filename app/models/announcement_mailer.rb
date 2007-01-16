class AnnouncementMailer < ActionMailer::Base
  def announcement(recipient)
    subject     'Candi Vanilla Update'
    recipients  [recipient]
    from       'Yann Blindert <nevens42@yahoo.com>'
  end
end
