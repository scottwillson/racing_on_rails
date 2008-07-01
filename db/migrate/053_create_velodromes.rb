class CreateVelodromes < ActiveRecord::Migration
  def self.up
    create_table :velodromes do |t|
      t.string :name
      t.string :website

      t.column :lock_version, :int, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :velodromes
  end
end
