class AddPrintCard < ActiveRecord::Migration
  def self.up
    add_column(:racers, :print_card, :boolean, :default => false)
  end

  def self.down
    remove_column(:racers, :print_card)
  end
end
