class AddResultBarOverride < ActiveRecord::Migration
  def self.up
    add_column :results, :bar, :boolean, :null => :false, :default => true
  end

  def self.down
    remove_column :results, :bar
  end
end
