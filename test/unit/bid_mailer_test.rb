require "test_helper"

class BidMailerTest < ActionMailer::TestCase
  
  def test_created
    @expected.subject = 'New Ridley Bid'
    @expected.body    = read_fixture('created')
    @expected.from = 'scott@butlerpress.com'
    @expected.to = 'cmurray@obra.org'
    date = Time.zone.now
    @expected.date = date
    
    bid = Bid.new(:name => 'Ryan Weaver', :amount => 2400, :email => 'ryan@weaver.com', :phone => '411')
    assert_equal(@expected.encoded, BidMailer.create_created(bid, date).encoded)
  end
end
