class AddVelodromeCommitteeInterest < ActiveRecord::Migration
  def change
    change_table :order_people do |t|
      t.boolean :velodrome_committee_interest
    end

    change_table :people do |t|
      t.boolean :velodrome_committee_interest
    end
  end
end
