class UnforkMbra < ActiveRecord::Migration
  def self.up
    drop_table(:new_categories) rescue nil
    
    return unless ASSOCIATION.short_name == "MBRA"
    
    execute "update disciplines set name = 'Cyclocross' where name = 'cyclocross'"
    execute "update disciplines set name = 'Mountain Bike' where name = 'mountain_bike'"
    execute "update disciplines set name = 'Road' where name = 'road'"
    
    execute "update events set discipline = 'Cyclocross' where discipline = 'cyclocross'"
    execute "update events set discipline = 'Mountain Bike' where discipline = 'mountain_bike'"
    execute "update events set discipline = 'Road' where discipline = 'road'"
    
    execute "update standings set discipline = 'Cyclocross' where discipline = 'cyclocross'"
    execute "update standings set discipline = 'Mountain Bike' where discipline = 'mountain_bike'"
    execute "update standings set discipline = 'Road' where discipline = 'road'"
    
    execute "update racers set team_id = null where team_id is not null and team_id not in (select id from teams)"
    execute "update results set team_id = null where team_id is not null and team_id not in (select id from teams)"
    
    create_table :roles, :force => true do |t|
      t.integer :id
      t.string :name
      t.timestamps
    end

    create_table :roles_users, :id => false do |t|
      t.integer :role_id, :null => false
      t.integer :user_id, :null => false
    end
    
    change_table :users do |t|
      t.string :email
    end
    
    create_table :velodromes, :force => true do |t|
      t.string :name
      t.string :website
      t.integer :lock_version, :default => 0
      t.timestamps
    end
  end
end
