class AddDisciplineBarCatsIndex < ActiveRecord::Migration
  def self.up
    add_index :discipline_bar_categories, [:category_id, :discipline_id], :unique => true
  end

  def self.down
  end
end
