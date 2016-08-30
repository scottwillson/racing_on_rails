class AddRacesSplitFrom < ActiveRecord::Migration
  def change
    change_table :races do |t|
      t.belongs_to :split_from
    end
  end
end
