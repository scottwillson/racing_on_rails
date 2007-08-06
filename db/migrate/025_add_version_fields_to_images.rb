class AddVersionFieldsToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :lock_version,  :integer,        :null => false, :default => 0
    add_column :images, :created_at,    :datetime
    add_column :images, :updated_at,    :datetime
  end

  def self.down
    drop_column :images, :lock_version
    drop_column :images, :created_at
    drop_column :images, :updated_at
  end
end
