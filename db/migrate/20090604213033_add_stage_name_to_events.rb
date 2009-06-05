class AddStageNameToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :stage_name, :string
  end

  def self.down
    remove_column :events, :stage_name
  end
end
