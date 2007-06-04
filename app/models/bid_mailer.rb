class BidMailer < ActionMailer::Base

  def created(bid)
    @subject    = 'New Ridley Bid'
    @recipients = 'cmurray@obra.org'
    @from       = 'scott@butlerpress.com'
    body(:bid => bid)
  end
end
