class UseCompetitionEventMemberships < ActiveRecord::Migration
  def self.up
    Event.find(:all, :conditions => "cat4_womens_race_series_id is not null").each do |event|
      cat4_womens_race_series_id = event.cat4_womens_race_series_id
      unless CompetitionEventMembership.find(:first, :conditions => { :event_id => event.id, :competition_id => cat4_womens_race_series_id })
        CompetitionEventMembership.create!(:event_id => event.id, :competition_id => cat4_womens_race_series_id)
      end
    end

    Event.find(:all, :conditions => "oregon_cup_id is not null").each do |event|
      oregon_cup_id = event.oregon_cup_id
      unless CompetitionEventMembership.find(:first, :conditions => { :event_id => event.id, :competition_id => oregon_cup_id })
        CompetitionEventMembership.create!(:event_id => event.id, :competition_id => oregon_cup_id)
      end
    end

    execute "alter table events drop foreign key events_oregon_cup_id_fk"
    remove_column :events, :cat4_womens_race_series_id
    remove_column :events, :oregon_cup_id
  end

  def self.down
    raise "Can't rollback"
  end
end
