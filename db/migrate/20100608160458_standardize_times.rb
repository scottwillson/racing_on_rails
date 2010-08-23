class StandardizeTimes < ActiveRecord::Migration
  def self.up
    change_table :results do |t|
      t.change :time, :double
      t.change :time_bonus_penalty, :double
      t.change :time_gap_to_leader, :double
      t.change :time_gap_to_previous, :double
      t.change :time_gap_to_winner, :double
    end
  end

  def self.down
  end
end