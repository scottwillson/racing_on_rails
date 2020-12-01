# frozen_string_literal: true

class AddCalculationUniqueConstraints < ActiveRecord::Migration[5.2]
  def change
    remove_index :calculations, name: "index_calculations_on_event_id"
    add_index :calculations, :event_id, unique: true

    remove_index :calculations_categories_mappings, name: "index_ccc_on_calculation_category_is_and_category_id"
    add_index :calculations_categories_mappings, %i[calculation_category_id category_id], unique: true, name: "index_ccc_on_calculation_category_id_and_category_id"

    add_index :calculations_categories, %i[calculation_id category_id], unique: true
    add_index :calculations_events, %i[calculation_id event_id], unique: true

    remove_foreign_key :result_sources, column: :calculated_result_id
    remove_foreign_key :result_sources, column: :source_result_id
    remove_index :result_sources, name: "calculated_result_id_source_result_id", force: true
    add_index :result_sources, %w[calculated_result_id source_result_id], unique: true, name: "index_r_sources_on_calc_result_id_and_source_result_id"
    add_foreign_key :result_sources, :results, column: :calculated_result_id, on_delete: :cascade
    add_foreign_key :result_sources, :results, column: :source_result_id, on_delete: :cascade
  end
end
