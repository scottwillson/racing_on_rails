class FlattenResults < ActiveRecord::Migration
  def self.up
    raise("Set SKIP_OBSERVERS to true before running this migration") unless ENV["SKIP_OBSERVERS"]
    change_table :results do |t|
      t.boolean :competition_result, :default => nil, :null => false
      t.boolean :team_competition_result, :default => nil, :null => false
      t.string :category_name, :default => nil
      t.string :event_date_range_s, :default => nil, :null => false
      t.date :date, :default => nil, :null => false
      t.date :event_end_date, :default => nil, :null => false
      t.integer :event_id, :default => nil, :null => false
      t.string :event_full_name, :default => nil, :null => false
      t.string :first_name, :default => nil
      t.string :last_name, :default => nil
      t.string :name, :default => nil
      t.string :race_name, :default => nil, :null => false
      t.string :race_full_name, :default => nil, :null => false
      t.string :team_name, :default => nil
      t.integer :year, :default => nil, :null => false
    end
    
    ActiveRecord::Base.lock_optimistically = false

    say "Cache #{Race.count} races"
    Race.find_each(:include => [ :event => :parent ]) do |race|
      Result.update_all [ "event_id = ?, race_full_name = ?, race_name = ?", race.event_id, race.full_name, race.name ], 
                        [ "race_id = ?", race.id ]
    end
    
    say "Cache #{Event.count} events"
    Event.find_each do |event|
      say "Cache #{event.name} #{event.date}"
      Result.update_all [ "event_full_name = ?, event_date_range_s = ?, event_end_date = ?, date = ?, competition_result = ?, team_competition_result = ?, year = ?", 
                          event.full_name, event.date_range_s(:long), event.end_date, event.date, event.is_a?(Competition), 
                          event.is_a?(TeamBar) || event.is_a?(CrossCrusadeTeamCompetition) || event.is_a?(MbraTeamBar), event.date.year ], 
                        [ "event_id = ?", event.id ]
    end
    
    say "Cache #{Result.count} results"
    index = 0
    Result.find_each(:include => [ { :person => :names }, :team, { :race => :event } ]) do |result|
      if index % 1000 == 0
        puts(index)
      end
      result.cache_non_event_attributes
      result.save!
      index = index + 1
    end

    ActiveRecord::Base.lock_optimistically = true

    change_table :results do |t|
      t.index :event_id
      t.index :year
    end
  end

  def self.down
    change_table :results do |t|
      t.remove :date
      t.remove :race_full_name
      t.remove :competition_result
      t.remove :team_competition_result
      t.remove :category_name
      t.remove :event_end_date
      t.remove :event_full_name
      t.remove :event_date_range_s
      t.remove :event_id
      t.remove :first_name
      t.remove :last_name
      t.remove :race_name
      t.remove :name
      t.remove :team_name
      t.remove :year
    end
  end
end
