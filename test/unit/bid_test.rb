require "test_helper"

class BidTest < ActiveSupport::TestCase
  def test_create
    Bid.create(:name => 'Craig', :email => 'craig@yahoo.com', :phone => '411', :amount => 20)
  end
  
  def test_highest
    assert_equal(10, Bid.highest.amount)

    Bid.create(:name => 'Craig', :email => 'craig@yahoo.com', :phone => '411', :amount => 20, :approved => true)
    assert_equal(20, Bid.highest.amount)

    bid = Bid.create(:name => 'Molly', :email => 'molly@veloshop.com', :phone => '411', :amount => 10000000)
    assert_equal(20, Bid.highest.amount)
    
    bid.approved = true
    bid.save!
    assert_equal(10000000, Bid.highest.amount)
  end
end
