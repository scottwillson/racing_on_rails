require File.dirname(__FILE__) + '/../test_helper'
require 'bid_mailer'

class BidMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_created
    @expected.subject = 'New Ridley Bid'
    @expected.body    = read_fixture('created')
    @expected.from = 'scott@butlerpress.com'
    @expected.to = 'cmurray@obra.org'
    
    bid = Bid.new(:name => 'Ryan Weaver', :amount => 2400, :email => 'ryan@weaver.com', :phone => '411')
    assert_equal @expected.encoded, BidMailer.create_created(bid).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/bids/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
