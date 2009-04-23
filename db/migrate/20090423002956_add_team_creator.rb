class AddTeamCreator < ActiveRecord::Migration
  def self.up
    add_column :teams, :created_by_id, :integer
    add_column :teams, :created_by_type, :string
  end

  def self.down
    remove_column :teams, :created_by_type
    remove_column :teams, :created_by_id
  end
end
