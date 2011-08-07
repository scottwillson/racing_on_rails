class RemoveExceptionRecipients < ActiveRecord::Migration
  def self.up
    remove_column :racing_associations, :exception_recipients
  end

  def self.down
    add_column :racing_associations, :exception_recipients, :text
  end
end