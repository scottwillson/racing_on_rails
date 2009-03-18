class SubscriptionsController < ApplicationController
  def new
    @subscription = Subscription.new
  end
  
  # Just an email contact form like FormMail for ATRA
  def create        
    @subscription = Subscription.new(params[:subscription])
    
    uri = URI.parse(request.env["HTTP_REFERER"])
    unless %w{ localhost app.americantrackracing.com raceatra.com www.raceatra.com}.include?(uri.host)
      flash[:notice] = "Cannot send request from '#{uri.host}'"
      return render(:action => "new")
    end

    if @subscription.valid?
      email = SubscriptionMailer.create_subscription_request(@subscription)
      SubscriptionMailer.deliver(email)
      redirect_to(:action => "subscribed")
    else
      render(:action => "new")
    end
  end
end
