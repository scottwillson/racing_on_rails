class BidMailer < ActionMailer::Base

  def created(bid, sent_on = Time.now)
    @subject    = 'New Ridley Bid'
    @recipients = 'cmurray@obra.org'
    @from       = 'scott@butlerpress.com'
    @sent_on    = sent_on
    body(:bid => bid)
  end
end
