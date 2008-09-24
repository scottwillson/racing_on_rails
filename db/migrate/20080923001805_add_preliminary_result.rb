class AddPreliminaryResult < ActiveRecord::Migration
  def self.up
    add_column :results, :preliminary, :boolean
  end

  def self.down
    remove_column :results, :preliminary
  end
end
