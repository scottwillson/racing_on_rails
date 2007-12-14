class AddDuplicates < ActiveRecord::Migration
  def self.up
    create_table :duplicates do |t|
      t.text  :new_attributes
    end
    
    create_table :duplicates_racers do |t|
      t.integer  :racer_id
      t.integer  :duplicate_id
    end    
  end

  def self.down
    drop_table :duplicates
    drop_table :duplicates_racers
  end
end
