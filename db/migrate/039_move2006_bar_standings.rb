class Move2006BarStandings < ActiveRecord::Migration
  def self.up
    return unless Bar.find_by_name('2006 BAR')
    Bar.transaction do
      overall_bar = OverallBar.create!(:date => Date.new(2006))
      overall_bar.standings.clear
      standings = Standings.find(5008)
      standings.event_id = overall_bar.id
      standings.save!

      team_bar = TeamBar.create!(:date => Date.new(2006))
      team_bar.standings.clear
      standings = Standings.find(5009)
      standings.event_id = team_bar.id
      standings.save!
    end
  end

  def self.down
  end
end
