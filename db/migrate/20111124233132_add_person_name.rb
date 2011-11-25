class AddPersonName < ActiveRecord::Migration
  def self.up
    add_column :people, :name, :string, :default => "", :null => false
    execute "update people set name=trim(concat_ws(' ', first_name, last_name))"
    add_index :people, :name
  end

  def self.down
    remove_index :people, :name
    remove_column :people, :name
  end
end