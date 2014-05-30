class RemoveEventNotification < ActiveRecord::Migration
  def change
    remove_column :events, :notification
  end
end
