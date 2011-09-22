class ChangeDistanceToString < ActiveRecord::Migration
  def self.up
    change_table :races do |t|
      t.change :distance, :string
    end
  end

  def self.down
    change_table :races do |t|
      t.change :distance, :integer
    end
  end
end