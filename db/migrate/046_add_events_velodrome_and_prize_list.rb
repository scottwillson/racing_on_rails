class AddEventsVelodromeAndPrizeList < ActiveRecord::Migration
  def self.up
    add_column :events, :velodrome, :string
    add_column :events, :prize_list, :string
  end

  def self.down
    remove_column :events, :prize_list
    remove_column :events, :velodrome
  end
end
