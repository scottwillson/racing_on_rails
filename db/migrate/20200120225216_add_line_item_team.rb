class AddLineItemTeam < ActiveRecord::Migration[5.2]
  def change
    change_table :line_items do |t|
      t.belongs_to :team, foreign_key: true, type: :integer
    end
  end
end
