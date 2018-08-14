class RemoveDiscountCodeCreatedBy < ActiveRecord::Migration
  def change
    change_table :discount_codes do |t|
      t.remove :created_by_id
      t.remove :created_by_type
    end
  end
end
