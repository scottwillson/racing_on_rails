class ManyPromoters < ActiveRecord::Migration
  def self.up
    create_table :events_people, :force => true, :id => false do |t|
      t.integer :event_id
      t.integer :person_id
      t.timestamps
    end
    
    add_index :events_people, :event_id
    add_index :events_people, :person_id
    
    execute "alter table events_people add foreign key (event_id) references events (id) on delete cascade"
    execute "alter table events_people add foreign key (person_id) references people (id) on delete cascade"
    
    Event.all(:conditions => "promoter_id is not null").each do |event|
      execute "insert into events_people(event_id, person_id, created_at) values(#{event.id}, #{event.promoter_id}, NOW())"
    end
    
    execute "alter table events drop foreign key events_promoter_id"
    remove_column :events, :promoter_id
  end

  def self.down
    add_column :events, :promoter_id, :integer
    remove_index :events_people, :person_id
    remove_index :events_people, :event_id
    drop_table :events_people

    execute "alter table events_people drop foreign key events_id"
    execute "alter table events_people drop foreign key person_id"
    execute "alter table events add foreign key (promoter_id) references people (id) on delete cascade"
  end
end
