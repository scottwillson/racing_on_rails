class EnlargeRacersNotes < ActiveRecord::Migration
  def self.up
    change_column(:racers, :notes, :string, :limit => 2048)
  end
end