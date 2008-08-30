class AddSeparateResultPointsBonusAndPenalty < ActiveRecord::Migration
  def self.up
    add_column :results, :points_bonus, :integer, :null => false, :default => 0
    add_column :results, :points_penalty, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :results, :points_bonus
    remove_column :results, :points_penalty
  end
end
