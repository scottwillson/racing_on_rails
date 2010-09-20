class AddCat4WomensSeriesEndDate < ActiveRecord::Migration
  def self.up
    change_table :racing_associations do |t|
      t.date :cat4_womens_race_series_end_date, :default => nil, :null => true
    end
    
    RacingAssociation.reset_column_information
    r = RacingAssociation.current
    if RacingAssociation.current.short_name == "WSBA"
      r.cat4_womens_race_series_end_date = Date.new(2010, 8, 21)
      r.save!
    end
  end

  def self.down
    change_table :racing_associations do |t|
      t.remove :cat4_womens_race_series_end_date
    end
  end
end
