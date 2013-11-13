class DropEventLockVersion < ActiveRecord::Migration
  def change
    remove_column :events, :lock_version
  end
end