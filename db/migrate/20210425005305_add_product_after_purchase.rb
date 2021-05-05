# frozen_string_literal: true

class AddProductAfterPurchase < ActiveRecord::Migration[6.1]
  def change
    change_table :products do |t|
      t.string :after_purchase_job
    end
  end
end
