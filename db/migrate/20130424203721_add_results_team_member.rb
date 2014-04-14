class AddResultsTeamMember < ActiveRecord::Migration
  def change
    add_column :results, :team_member, :boolean, default: false, null: false
    
    puts "Populate Result#team_member for #{Result.count} results"
    Result.reset_column_information
    Result.includes(:team).find_each do |r| 
      r.update_column(:team_member, r.team.member?) if r.team_id
    end
  end
end