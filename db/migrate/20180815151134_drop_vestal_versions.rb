class DropVestalVersions < ActiveRecord::Migration[4.2]
  def change
    drop_table :versions
  end
end
