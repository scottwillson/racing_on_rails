class Standings < ActiveRecord::Base
  belongs_to :event
  has_many :races
  has_one :combined_standings, :class_name => "CombinedStandings", :foreign_key => 'source_id'

  def date
    self.event.date if self.event
  end

  def name
    self[:name] || self.event.name if self.event
  end
end

class CombinedStandings < Standings; 
  belongs_to :source, 
             :class_name => 'Standings', 
             :foreign_key => 'source_id'
end
class CombinedTimeTrialStandings < CombinedStandings; end
class CombinedMountainBikeStandings < CombinedStandings; end
class CascadeCrossSeriesStandings < Standings; end
class CrossCrusadeSeriesStandings < Standings; end
class TaborSeriesStandings < Standings; end

Event.class_eval do
  has_many :standings, :class_name => "Standings"
end

Race.class_eval do
  belongs_to :standings
end

class ReplaceStandingsWithEvents < ActiveRecord::Migration
  
  def self.up
    unless Result.count_by_sql("select count(*) from results where race_id is null or race_id = 0") == 0
      raise "Found orphaned results with no race"
    end
    
    unless Race.count_by_sql("select count(*) from races where standings_id is null or standings_id = 0") == 0
      raise "Found orphaned races with no standings"
    end

    add_column :races, :event_id, :integer, :null => false, :default => nil
    add_index :races, :event_id
    execute "alter table races alter column category_id drop default"
    
    add_column :events, :bar_points, :integer, :null => false, :default => nil
    execute("alter table races drop foreign key races_ibfk_2") rescue nil
    add_column :events, :ironman, :boolean, :null => false, :default => nil
    execute("alter table events modify type varchar(32) default null")
    add_column :events, :auto_combined_results, :boolean, :default => true, :null => false
    add_column :events, :source_event_id, :integer, :default => nil
    add_index :events, :type
    remove_index :events, :name => :idx_date
    execute "create index idx_date on events (date asc)"
    execute "alter table events add foreign key (source_event_id) references events (id)"

    create_table :competition_event_memberships, :force => true, :primary => false do |t|
      t.integer :competition_id, :null => false, :default => nil
      t.integer :event_id, :null => false, :default => nil
    end
    add_index :competition_event_memberships, :competition_id
    add_index :competition_event_memberships, :event_id
    execute "alter table competition_event_memberships add foreign key (competition_id) references events (id) on delete cascade"
    execute "alter table competition_event_memberships add foreign key (event_id) references events (id) on delete cascade"

    execute("alter table results alter column race_id drop default ")
    # Not really related. Drop unused column.
    remove_column :results, :date

    execute "alter table pages add foreign key (parent_id) references pages (id) on delete restrict"
    execute "alter table roles_users add foreign key (role_id) references roles (id) on delete cascade"
    execute "delete from roles_users where user_id not in (select id from users)"
    execute "alter table users engine = innodb"
    execute "alter table roles_users add foreign key (user_id) references users (id) on delete cascade"
    
    add_index :disciplines, :name, :unique => true
    add_index :events, :sanctioned_by
    add_index :page_versions, :page_id
    add_index :pages, :slug
    add_index :racers, :member_to
    add_index :racers, :member_from
    add_index :events, :bar_points
    add_index :races, :bar_points
    add_index :results, :place
    add_index :results, :members_only_place
    add_index :users, :name
    add_index :users, :email, :unique => true
    add_index :velodromes, :name

    Race.reset_column_information
    Event.reset_column_information
    Result.reset_column_information
    
    # Fix circular dependency from old data
    execute "update events set parent_id = null where parent_id=13228"
    Event.destroy(13869) if Event.exists?(13869)
    
    # TODO: Do without updating updated_at
    execute "update events set notification = false"
    execute "update events set auto_combined_results = false where date < '2009-01-01'"
    execute "update events set ironman = false, bar_points = 0 where type != 'SingleDayEvent'"

    Standings.find(
      :all,
      :order => "id",
      :conditions => "type in ('CombinedTimeTrialStandings', 'CombinedMountainBikeStandings', 'TaborSeriesStandings', 'CrossCrusadeSeriesStandings', 'CascadeCrossSeriesStandings')").each do |standings|
      case standings
      when CombinedMountainBikeStandings
        convert_mtb_standings(standings)
      when CombinedTimeTrialStandings
        convert_tt_standings(standings)
      when CrossCrusadeSeriesStandings
        convert_overall(standings)
      when CascadeCrossSeriesStandings
        convert_overall(standings)
      when TaborSeriesStandings
        convert_overall(standings)
      else
        raise "Unknown Standings: #{standings.class}"
      end
    end

    Standings.find(
      :all, 
      :order => "id",
      :conditions => "type in ('', 'Standings') or type IS NULL").each do |standings|
      convert_standings(standings)
    end

    execute "alter table races add foreign key (event_id) references events (id) on delete cascade"
    execute "update events set notification = true"

    remove_column :races, :standings_id
    drop_table :standings
    drop_table(:comatose_page_versions) rescue true
    drop_table(:comatose_pages) rescue true
    drop_table(:images) rescue true
    drop_table(:news_items) rescue true
    
    unless Result.count_by_sql("select count(*) from results where race_id is null or race_id = 0") == 0
      raise "Found orphaned results with no race"
    end
    
    unless Race.count_by_sql("select count(*) from races where event_id is null or event_id = 0") == 0
      raise "Found orphaned races with no event"
    end
  end
  
  def self.convert_standings(standings)
    standings_count = standings.event.standings.count(:conditions => "type in ('', 'Standings') or type is NULL") 
    say "Standings #{standings_count} #{standings.event.date} #{standings.event.name} #{standings.name} #{standings.event.id} #{standings.id} #{standings.type}"
    case standings_count
    when 0
      raise "Unexpected standings_count of 0"
    when 1
      event = standings.event
    else
      if standings.name == standings.event.name && standings.event.standings.count(:conditions => { :name => standings.event.name }) == 1
        event = standings.event
      else
        event = standings.event.children.create!(:name => standings.name)
        event.disable_notification!
      end
    end

    event.bar_points = standings.bar_points
    event.ironman = standings.ironman
    # Use Standings' names for stages of a stage race, but not for the stage race itself
    event.name = standings.name unless event.parent.nil?
    event.save!
    standings.races.each do |race|
      race.event = event
      race.save!
    end

    combined_standings = CombinedTimeTrialStandings.find_by_source_id(standings.id)
    if combined_standings
      combined = event.children.create!(:parent => event, :name => "Combined Results by Time", :bar_points => 0, :ironman => false, :date => combined_standings.event.date)
      combined_standings.races.each do |race|
        race.event = combined
        race.save!
      end
    end
  end
  
  def self.convert_overall(standings)
    say "Overall #{standings.event.date} #{standings.event.name} #{standings.name} #{standings.event.id} #{standings.id} #{standings.type}"
    event = standings.event.children.create!(:name => standings.name)
    event.disable_notification!
    event.bar_points = standings.bar_points
    event.ironman = standings.ironman
    event.name = standings.name
    event.save!
    standings.races.each do |race|
      race.event = event
      race.save!
    end
  end
  
  def self.convert_mtb_standings(standings)
    say "MTB #{standings.event.date} #{standings.event.name} #{standings.event.id} #{standings.name} #{standings.id} #{standings.source_id}"
    standings.races.each do |race|
      race.event = standings.event
      race.save!
    end
  end
  
  def self.convert_tt_standings(standings)
    say "TT #{standings.event.date} #{standings.event.name} #{standings.event.id} #{standings.name} #{standings.id} #{standings.source_id}"
    if standings.event.combined_results
      combined_event = standings.source.event.children.create!
      combined_event.bar_points = standings.bar_points
      combined_event.ironman = standings.ironman
      combined_event.save!
      standings.races.each do |race|
        race.event = combined_event
        race.save!
      end
    else
      event = standings.source.event
      combined = event.children.create!(:parent => event, :name => "Combined Results by Time", :bar_points => 0, :ironman => false, :date => standings.event.date)
      standings.races.each do |race|
        race.event = combined
        race.save!
      end
    end
  end

  def self.down
    add_index :events, :date, :name => :idx_date
    remove_index :events, :type
    remove_index :races, :event_id
    add_column :results, :date, :date
    create_table "standings", :force => true do |t|
      t.integer  "event_id",                              :default => 0,    :null => false
      t.integer  "bar_points",                            :default => 1
      t.string   "name"
      t.integer  "lock_version",                          :default => 0,    :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "ironman",                               :default => true
      t.integer  "position",                              :default => 0
      t.string   "discipline",              :limit => 32
      t.string   "notes",                                 :default => ""
      t.integer  "source_id"
      t.string   "type",                    :limit => 32
      t.boolean  "auto_combined_standings",               :default => true
    end
    
    add_column :races, :standings_id, :integer,                  :default => 0,      :null => false
    remove_column :events, :source_event_id
    remove_index :competition_event_memberships, :event_id
    remove_index :competition_event_memberships, :competition_id
    drop_table :competition_event_memberships
    remove_column :events, :auto_combined_results
    remove_column :events, :ironman
    remove_column :events, :bar_points
    remove_column :races, :event_id
    execute("alter table events ALTER type set DEFAULT ''")
  end
end
