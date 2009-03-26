class CreateImportFiles < ActiveRecord::Migration
  def self.up
    create_table :import_files, :force => true do |t|
      t.string :name, :null => false, :default => "Import File"
      t.integer :lock_version, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :import_files
  end
end
