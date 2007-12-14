class FixDuplicatesRacersConstraints < ActiveRecord::Migration
  def self.up
    create_table :duplicates_racers, :id => false, :force => true do |t|
      t.integer  :racer_id, :references => :racers, :on_delete => :cascade
      t.integer  :duplicate_id, :references => :duplicates, :on_delete => :cascade
    end
    add_index :duplicates_racers, [:racer_id, :duplicate_id], :unique => true
    add_index :duplicates_racers, :racer_id
    add_index :duplicates_racers, :duplicate_id
  end

  def self.down
    create_table :duplicates_racers, :id => false, :force => true do |t|
      t.integer  :racer_id
      t.integer  :duplicate_id
    end    
  end
end
