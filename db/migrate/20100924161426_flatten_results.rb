class FlattenResults < ActiveRecord::Migration
  def self.up
    change_table :results do |t|
      t.string :category_name, :default => nil
      t.string :first_name, :default => nil
      t.string :last_name, :default => nil
      t.string :name, :default => nil
      t.string :team_name, :default => nil
      t.integer :year, :default => nil, :null => false
    end
    
    # Add migration, and be sure to not trigger combined results recalc
    # Add indexes
    # Disable notification in observers
  end

  def self.down
    change_table :results do |t|
      t.remove :category_name
      t.remove :first_name
      t.remove :last_name
      t.remove :name
      t.remove :team_name
      t.remove :year
    end
  end
end
