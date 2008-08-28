class CreateNames < ActiveRecord::Migration
  def self.up
    create_table :names, :force => true do |t|
      t.integer :team_id, :null => false
      t.string :name, :null => false
      t.integer :year, :null => false
      t.timestamps
    end
    execute("alter table names add foreign key (team_id) references teams (id)")
    add_index :names, :name
    add_index :names, :year
  end

  def self.down
    remove_index :names, :name
    remove_index :names, :year
    drop_table :names
  end
end
