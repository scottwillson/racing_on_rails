class AddResultAgeGroup < ActiveRecord::Migration
  def self.up
    add_column(:results, :age_group, :string) rescue nil
  end

  def self.down
    remove_column :results, :age_group
  end
end
