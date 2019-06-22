# frozen_string_literal: true

class CreateCalculations < ActiveRecord::Migration[5.2]
  def change
    create_table :calculations, force: true do |t|
      t.references :discipline
      t.references :event
      t.references :source_event
      t.boolean :association_sanctioned_only, default: false, null: false
      t.boolean :double_points_for_last_event, default: false, null: false
      t.boolean :members_only, default: false, null: false
      t.integer :minimum_events, default: 0, null: false
      t.integer :maximum_events, default: 0, null: false
      t.integer :missing_result_penalty, default: nil, null: true
      t.boolean :most_points_win, default: true, null: false
      t.string :key
      t.string :name, default: "New Calculation", required: true, unique: true
      t.text :points_for_place, array: true
      t.integer :results_per_event, default: nil, null: true
      t.string :source_event_keys, array: true, default: [].to_yaml
      t.boolean :specific_events, default: false, null: false
      t.boolean :team, default: false, null: false
      t.boolean :weekday_events, default: true, null: false
      t.integer :year, default: nil, null: false

      t.index %i[key year], unique: true

      t.timestamps
    end
  end
end
