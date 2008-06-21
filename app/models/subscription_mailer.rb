class SubscriptionMailer < ActionMailer::Base

  def subscription_request(subscription)
    @subject    = "Mailing List Subscription: #{subscription.name}"
    @recipients = 'scott@butlerpress.com'
    # @recipients = 'webmaster@americantrackracing.com'
    @from       = "#{subscription.name} <#{subscription.email}>"
    body :subscription => subscription
  end
end
