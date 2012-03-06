class CreateEditorsEvents < ActiveRecord::Migration
  def self.up
    create_table :editors_events, :force => true, :id => false do |t|
      t.integer :event_id, :null => false
      t.integer :editor_id, :null => false
    end 

    add_index :editors_events, :event_id   
    add_index :editors_events, :editor_id   
  end

  def self.down
    drop_table :editors_events
  end
end
