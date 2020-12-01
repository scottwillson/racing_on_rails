# frozen_string_literal: true

class AddCalculationCategoryDiscipline < ActiveRecord::Migration[5.2]
  def change
    add_column :calculations_categories_categories, :discipline_id, :integer, default: nil, null: true
    add_foreign_key :calculations_categories_categories, :disciplines, column: :discipline_id, on_delete: :cascade
    rename_table :calculations_categories_categories, :calculations_categories_mappings
  end
end
