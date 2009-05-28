class AddTeamToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :team_id, :integer
  end

  def self.down
    remove_column :events, :team_id
  end
end
