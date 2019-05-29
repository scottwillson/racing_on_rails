# frozen_string_literal: true

class CreateResultSources < ActiveRecord::Migration[5.2]
  def change
    create_table :result_sources, force: true do |t|
      t.integer :calculated_result_id, default: nil, null: false
      t.decimal :points, precision: 10, default: "0", null: false
      t.string :rejection_reason
      t.integer :source_result_id, default: nil, null: false
      t.index %i[calculated_result_id source_result_id], name: :calculated_result_id_source_result_id
      t.timestamps
    end

    add_foreign_key :result_sources, :results, column: :calculated_result_id, on_delete: :cascade
    add_foreign_key :result_sources, :results, column: :source_result_id, on_delete: :cascade
  end
end
