class AddLineItemsIndexes < ActiveRecord::Migration[5.2]
  def change
    change_table :line_items do |t|
      t.index :status
      t.index :type
    end
  end
end
