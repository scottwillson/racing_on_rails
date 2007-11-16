class FixCompetitionNames < ActiveRecord::Migration
  def self.up
    Competition.transaction do
      Competition.find(:all, :conditions => ['name is null']).each do |competition|
        competition.name
        competition.save!
      end      
    end
  end

  def self.down
  end
end
