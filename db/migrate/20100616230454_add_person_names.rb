class AddPersonNames < ActiveRecord::Migration
  def self.up
    execute "alter table names drop foreign key historical_names_team_id_fk"
    
    change_table :names do |t|
      # t.string :nameable_type
      # t.string :first_name
      # t.string :last_name
      t.rename :team_id, :nameable_id
      t.index :nameable_type
    end
  end

  def self.down
    change_table :names do |t|
      t.remove :first_name
      t.remove :last_name
      t.remove :nameable_type
      t.rename :nameable_id, :team_id
    end
  end
end
