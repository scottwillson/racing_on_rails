class AddResultsTeamMember < ActiveRecord::Migration
  def change
    add_column :results, :team_member, :boolean, :default => false, :null => false
  end
end