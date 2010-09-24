class RemoveUniqueLoginIndex < ActiveRecord::Migration
  def self.up
    remove_index :people, :login
    add_index :people, :login
  end

  def self.down
    add_index :people, :login
    remove_index :people, :login
  end
end
