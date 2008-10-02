class AddTrackScheduleEventFields < ActiveRecord::Migration
  def self.up
    add_column :events, :time, :string
    add_column :events, :instructional, :boolean, :default => false
    add_column :events, :practice, :boolean, :default => false
  end

  def self.down
    remove_column :events, :practice
    remove_column :events, :instructional
    remove_column :events, :time
  end
end
