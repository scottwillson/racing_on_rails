class RemoveStageNameFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :stage_name
  end

  def self.down
    add_column :events, :stage_name, :string
  end
end
