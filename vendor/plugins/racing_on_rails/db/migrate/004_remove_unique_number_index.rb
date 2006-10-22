class RemoveUniqueNumberIndex < ActiveRecord::Migration
  def self.up
    remove_index(:race_numbers, :name => 'unique_numbers')
  end
end
