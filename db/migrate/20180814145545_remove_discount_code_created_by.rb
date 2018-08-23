class RemoveDiscountCodeCreatedBy < ActiveRecord::Migration[4.2]
  def change
    change_table :discount_codes do |t|
      t.remove :created_by_id
      t.remove :created_by_type
    end
  end
end
