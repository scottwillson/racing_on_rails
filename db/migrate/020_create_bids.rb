class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.column :id,           :primary_key
      t.column :name,         :string,     :null => false
      t.column :email,        :string,     :null => false
      t.column :phone,        :string,     :null => false
      t.column :amount,       :int,        :null => false
      t.column :approved,     :boolean
      t.column :lock_version, :int,        :null => false, :default => 0
      t.column :created_at,   :datetime
      t.column :updated_at,   :datetime
    end
    
  end

  def self.down
    drop_table :bids
  end
end
