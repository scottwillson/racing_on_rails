require File.dirname(__FILE__) + '/../test_helper'
require 'subscriptions_controller'

# Re-raise errors caught by the controller.
class SubscriptionsController; def rescue_action(e) raise e end; end

class SubscriptionsControllerTest < ActiveSupport::TestCase

  def setup
    @controller = SubscriptionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    MailingListMailer.deliveries = []
  end
  
  def test_new
    get(:new)
    assert_response(:success)
    assert_not_nil(assigns(:subscription), "Should assign subscription")
  end
  
  def test_create
    @request.env["HTTP_REFERER"] = "http://app.atra.obra.org/subscriptions/new"
    post(:create, :subscription => {"name"=>"Scott Willson", "city"=>"Portland", "sponsorship"=>"sponsorship", "zip"=>"97202", "Commit"=>"Join ATRA Mailing List", "comments"=>"This is a test", "volunteer"=>"volunteer", "action"=>"subscribe", "youth_programs"=>"on", "racer_info"=>"on", "controller"=>"mailing_lists", "phone"=>"503 913-6013", "race_results"=>"on", "address"=>"1204 SE Pershing St.", "contribution"=>"contribution", "email"=>"scott@butlerpress.com", "state"=>"OR"})
    
    assert_redirected_to :action => "subscribed"
    assert(flash.empty?, "Flash should be empty")

    assert_equal(1, MailingListMailer.deliveries.size, "Should have one email delivery")
    delivered_mail = MailingListMailer.deliveries.first
    assert_equal("Mailing List Subscription: Scott Willson", delivered_mail.subject, "Subject")
    assert_equal(["scott@butlerpress.com"], delivered_mail.from, "From email")
    assert_equal("Scott Willson", delivered_mail.friendly_from, "From Name")
    assert_equal(["webmaster@americantrackracing.com"], delivered_mail.to, "Recipient")
  end
  
  def test_subscribe_validation
    @request.env["HTTP_REFERER"] = "http://app.atra.obra.org/subscriptions/new"
    post(:create, :subscription => {"city"=>"Portland", "sponsorship"=>"sponsorship", "zip"=>"97202", "Commit"=>"Join ATRA Mailing List", "comments"=>"This is a test", "volunteer"=>"volunteer", "action"=>"subscribe", "youth_programs"=>"on", "racer_info"=>"on", "controller"=>"mailing_lists", "phone"=>"503 913-6013", "race_results"=>"on", "address"=>"1204 SE Pershing St.", "contribution"=>"contribution", "state"=>"OR"})

    assert_response(:success)
    assert_not_nil(assigns(:subscription), "Should assign subscription")
    assert(!assigns(:subscription).valid?, "Subscription should not be valid")
  end
  
  def test_validate_subscribe_referrer
    @request.env["HTTP_REFERER"] = "http://spambot.net/spammer"
    post(:create, :subscription => {"name"=>"Scott Willson", "city"=>"Portland", "sponsorship"=>"sponsorship", "zip"=>"97202", "Commit"=>"Join ATRA Mailing List", "comments"=>"This is a test", "volunteer"=>"volunteer", "action"=>"subscribe", "youth_programs"=>"on", "racer_info"=>"on", "controller"=>"mailing_lists", "phone"=>"503 913-6013", "race_results"=>"on", "address"=>"1204 SE Pershing St.", "contribution"=>"contribution", "email"=>"scott@butlerpress.com", "state"=>"OR"})
    assert_response(:success)
    assert_not_nil(assigns(:subscription), "Should assign subscription")
    assert_equal(0, MailingListMailer.deliveries.size, "Should have no email delivery")
    assert(!flash.empty?, "Flash should not be empty")
  end
  
  def test_subscribed
    get(:subscribed)
    assert_response(:success)
  end
end
