class AddCalculationCategoryMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :calculations_categories_categories, force: true do |t|
      t.belongs_to :calculation_category, index: { name: :index_ccc_on_calculation_category_id }
      t.belongs_to :category, index: true, type: :integer
      t.index %i[calculation_category_id category_id], name: :index_ccc_on_calculation_category_is_and_category_id
    end

    add_foreign_key :calculations_categories_categories, :calculations_categories, column: :calculation_category_id, on_delete: :cascade
    add_foreign_key :calculations_categories_categories, :categories, column: :category_id, on_delete: :cascade
  end
end
