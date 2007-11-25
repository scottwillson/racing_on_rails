class CreateNumberIssuers < ActiveRecord::Migration
  def self.up
    NumberIssuer.create!(:name => 'Cross Crusade')
    NumberIssuer.create!(:name => 'Mt Hood Cycling Classic')
    NumberIssuer.create!(:name => 'Elkhorn Classic Stage Race')
  end

  def self.down
  end
end
