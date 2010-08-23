class CreateVestalVersions < ActiveRecord::Migration
  def self.up
    create_table :versions, :force => true do |t|
      t.belongs_to :versioned, :polymorphic => true
      t.belongs_to :user, :polymorphic => true
      t.string :user_name
      t.text :changes
      t.integer :number
      t.string :tag

      t.timestamps
    end

    change_table :versions do |t|
      t.index [:versioned_id, :versioned_type]
      t.index [:user_id, :user_type]
      t.index :user_name
      t.index :number
      t.index :tag
      t.index :created_at
    end
    
    rename_column :people, :updated_by, :last_updated_by
  end

  def self.down
    rename_column :people, :last_updated_by, :updated_by
    drop_table :versions
  end
end
