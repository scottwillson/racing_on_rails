class AddDisciplineToRaceNumbersIndex < ActiveRecord::Migration
  def self.up
    remove_index(:race_numbers, :name => 'unique_numbers')
    add_index(:race_numbers, [:value, :discipline_id, :number_issuer_id, :year], :unique => true, :name => 'unique_numbers')
  end

  def self.down
  end
end
