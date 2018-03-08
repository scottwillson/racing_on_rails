class AddVelodromeCommitteeInterest < ActiveRecord::Migration
  def change
    change_table :order_people do |t|
      t.boolean :velodrome_committee_interest, default: false, null: false
    end

    change_table :people do |t|
      t.boolean :velodrome_committee_interest, default: false, null: false
    end
  end
end
