class AddUniqueTeamNameIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :teams, name: :index_teams_on_name
    add_index :teams, :name, unique: true
  end
end
