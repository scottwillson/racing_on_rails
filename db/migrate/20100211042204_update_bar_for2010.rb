class UpdateBarFor2010 < ActiveRecord::Migration
  def self.up
    downhill = Discipline[:downhill]
    downhill.bar_categories.clear
    downhill.bar = false
    downhill.save!
  end

  def self.down
  end
end
