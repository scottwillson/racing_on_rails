class AddSanctioningOrgEventIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :sanctioning_org_event_id, :string, :limit => 16
  end

  def self.down
    remove_column :events, :sanctioning_org_event_id
  end
end
