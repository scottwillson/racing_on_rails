class SetBarParents < ActiveRecord::Migration
  def self.up
    OverallBar.all.each do |overall_bar|
      overall_bar.children = Bar.find.all( :conditions => { :date => overall_bar.date })

      age_graded_bar = AgeGradedBar.find_by_date(overall_bar.date)
      if age_graded_bar
        overall_bar.children << age_graded_bar
      end

      team_bar = TeamBar.find_by_date(overall_bar.date)
      if team_bar
        team_bar.discipline = "Team"
        team_bar.save!
        overall_bar.children << team_bar
      end

      overall_bar.discipline = "Overall"
      overall_bar.save!
    end
  end

  def self.down
    Bar.update_all "parent_id = null"
    AgeGradedBar.update_all "parent_id = null"
    TeamBar.update_all "parent_id = null"
  end
end
