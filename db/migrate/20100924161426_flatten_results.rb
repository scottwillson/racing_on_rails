class FlattenResults < ActiveRecord::Migration
  def self.up
    change_table :results do |t|
      t.boolean :competition_result, :default => nil, :null => false
      t.boolean :team_competition_result, :default => nil, :null => false
      t.string :category_name, :default => nil
      t.string :first_name, :default => nil
      t.string :last_name, :default => nil
      t.string :name, :default => nil
      t.string :team_name, :default => nil
      t.integer :year, :default => nil, :null => false
      t.index :year
    end
    
    Result.transaction do
      ActiveRecord::Base.lock_optimistically = false
      Event.update_all "notification = false"
      ActiveRecord::Base.lock_optimistically = true
      
      Result.find_each(:include => [ { :race => :event }, :person, :team ]) do |result|
        result.cache_attributes
        result.save!
      end

      ActiveRecord::Base.lock_optimistically = false
      Event.update_all "notification = true"
      ActiveRecord::Base.lock_optimistically = true
    end
  end

  def self.down
    change_table :results do |t|
      t.remove :competition_result
      t.remove :team_competition_result
      t.remove :category_name
      t.remove :first_name
      t.remove :last_name
      t.remove :name
      t.remove :team_name
      t.remove :year
    end
  end
end
