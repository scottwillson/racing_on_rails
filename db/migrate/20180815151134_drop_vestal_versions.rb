class DropVestalVersions < ActiveRecord::Migration
  def change
    drop_table :versions
  end
end
