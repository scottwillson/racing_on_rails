# frozen_string_literal: true

class CreateCalculationsCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :calculations_categories, force: true do |t|
      t.belongs_to :calculation, index: true
      t.belongs_to :category, index: true
      t.integer :maximum_events, default: nil, null: true
      t.boolean :reject, default: false, null: false
      t.timestamps
    end
  end
end
