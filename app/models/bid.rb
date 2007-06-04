class Bid < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :phone
  validates_presence_of :amount
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create
  validate {|r| r.errors.add(:amount, 'must be greater than highest bid') if r.amount.nil? || r.amount <= Bid.highest.amount}
  
  def Bid.highest
    Bid.find(:first, :conditions => ['approved = ?', true], :order => 'amount desc', :limit => 1) || Bid.new(:amount => 10)
  end
end
