class AddPrintMailingLabel < ActiveRecord::Migration
  def self.up
    add_column(:racers, :print_mailing_label, :boolean, :default => false)
  end

  def self.down
    remove_column(:racers, :print_mailing_label)
  end
end
