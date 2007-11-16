class UpdateBarDisciplines < ActiveRecord::Migration
  def self.up
	for bar in OverallBar.find(:all)
		bar.discipline = 'Overall'
		bar.save!
		for standings in bar.standings(true)
			standings.discipline = 'Overall'
			standings.save!
		end
	end
  end

  def self.down
  end
end
