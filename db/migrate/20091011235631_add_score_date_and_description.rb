class AddScoreDateAndDescription < ActiveRecord::Migration
  def self.up
    change_table :scores do |t|
      t.date :date, :default => nil, :null => true
      t.string :description, :default => nil, :null => true
      t.string :event_name, :default => nil, :null => true
    end
  end

  def self.down
    change_table :scores do |t|
      t.remove :date
      t.remove :description
      t.remove :event_name
    end
  end
end
