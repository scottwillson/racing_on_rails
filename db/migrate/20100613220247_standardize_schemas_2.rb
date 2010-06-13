class StandardizeSchemas2 < ActiveRecord::Migration
  def self.up
    change_table :article_categories do |t|
      t.remove(:integer) rescue nil
    end

    change_table :articles do |t|
      t.remove(:integer) rescue nil
    end
    
    execute "alter table discipline_bar_categories convert to character set utf8"
    
    change_table :events do |t|
      t.boolean(:atra_points_series) rescue nil
    end
    
    change_table :people do |t|
      t.remove(:string) rescue nil
    end
    
    change_table :results do |t|
      t.remove(:old_time_bonus_penalty) rescue nil
    end
    
    change_table :velodromes do |t|
      t.change :lock_version, :integer, :null => false, :default => 0
    end
    
    remove_index(:people, :name => "racers") rescue nil
    add_index(:people, :email) rescue nil
    add_index(:people, :license) rescue nil
    add_index(:people, :print_card) rescue nil
  end

  def self.down
  end
end