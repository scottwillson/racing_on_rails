# After first unfork and UTF-8 conversion
class UnforkMbra2 < ActiveRecord::Migration
  def self.up
    execute "alter table people drop foreign key racers_team_id_fk" rescue nil
    execute "alter table people add constraint `people_team_id_fk` foreign key (`team_id`) references `teams` (`id`)"
    
    change_table :scores do |t|
      t.change :points, :float, :default => nil
    end
    
    unless ASSOCIATION.short_name == "MBRA"
      change_table :people do |t|
        t.change :gender, :string, :limit => 2, :default => nil
        t.date :license_expiration_date, :default => nil
        t.string :club_name, :default => nil
        t.string :ncca_club_name, :default => nil
      end
    
      change_table :roles do |t|
        t.timestamps
      end
    end

    if ASSOCIATION.short_name == "MBRA"
      create_table :bids, :force => true do |t|
        t.string :name, :null => false
        t.string :email, :null => false
        t.string :phone, :null => false
        t.integer :amount, :null => false
        t.boolean :approved, :default => nil
        t.integer :lock_version, :null => false, :default => 0
        t.timestamps
      end

      execute "update events set notes = trim(concat(concat(notes, ' '), short_description)) where short_description is not null and short_description != ''"
      execute "update events set sanctioning_org_event_id = trim(usac_event_number) where usac_event_number is not null and usac_event_number != ''"
      change_table :events do |t|
        t.remove :short_description
        t.remove :usac_event_number
      end

      change_table :people do |t|
        t.boolean :volunteer_interest, :null => false, :default => false
        t.boolean :official_interest, :null => false, :default => false
        t.boolean :race_promotion_interest, :null => false, :default => false
        t.boolean :team_interest, :null => false, :default => false
      end

      change_table :results do |t|
        t.integer :age, :default => nil
        t.rename :time, :old_time
        t.rename :time_gap_to_leader, :old_time_gap_to_leader
        t.rename :time_gap_to_previous, :old_time_gap_to_previous
        t.rename :time_gap_to_winner, :old_time_gap_to_winner
        t.rename :time_total, :old_time_total
        t.rename :time_bonus_penalty, :old_time_bonus_penalty
        t.float :time, :default => nil
        t.float :time_gap_to_leader, :default => nil
        t.float :time_gap_to_previous, :default => nil
        t.float :time_gap_to_winner, :default => nil
        t.float :time_total, :default => nil
        t.float :time_bonus_penalty, :default => nil
      end

      execute "update results set time = time_to_sec(old_time) where old_time is not null"
      execute "update results set time_gap_to_leader = time_to_sec(old_time_gap_to_leader) where old_time_gap_to_leader is not null"
      execute "update results set time_gap_to_previous = time_to_sec(old_time_gap_to_previous) where old_time_gap_to_previous is not null"
      execute "update results set time_gap_to_winner = time_to_sec(old_time_gap_to_winner) where old_time_gap_to_winner is not null"
      execute "update results set time_total = time_to_sec(old_time_total) where old_time_total is not null"
      execute "update results set time_bonus_penalty = time_to_sec(old_time_bonus_penalty) where old_time_bonus_penalty is not null"

      change_table :results do |t|
        t.remove :old_time
        t.remove :old_time_gap_to_leader
        t.remove :old_time_gap_to_previous
        t.remove :old_time_gap_to_winner
        t.remove :old_time_total
      end
    end
  
    remove_shadow_aliases
    execute "alter table aliases add constraint aliases_team_id_fk foreign key (team_id) references teams (id) on delete cascade" rescue nil
    
    change_table :categories do |t|
      t.change_default :name, nil
    end

    change_table :posts do |t|
      t.change :date, :timestamp, :default => nil
    end
  end
  
  def self.remove_shadow_aliases
    Alias.find.all().each do |a|
      if (a.team && Team.exists?(['name = ?', a.name])) || (a.person && Person.exists?(["trim(concat(first_name, ' ', last_name)) = ?", a.name]))
        say a.name
        a.destroy
      end
    end
  end
end
