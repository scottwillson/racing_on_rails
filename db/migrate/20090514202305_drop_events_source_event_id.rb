class DropEventsSourceEventId < ActiveRecord::Migration
  def self.up
    execute "alter table events drop foreign key events_source_event_id_fk"
    remove_column :events, :source_event_id
  end

  def self.down
    add_column :events, :source_event_id, :integer, :default => nil
    execute "alter table events add constraint events_source_event_id_fk foreign key (source_event_id) references events (id) on delete cascade"
  end
end
