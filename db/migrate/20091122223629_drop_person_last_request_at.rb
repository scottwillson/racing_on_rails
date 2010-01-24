class DropPersonLastRequestAt < ActiveRecord::Migration
  def self.up
    remove_column :people, :last_request_at
  end

  def self.down
    add_column :people, :last_request_at, :datetime
  end
end
