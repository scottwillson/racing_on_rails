# frozen_string_literal: true

class CreateCalculations < ActiveRecord::Migration[5.2]
  def change
    create_table :calculations, force: true do |t|
      t.references :event
      t.references :source_event
      t.boolean :double_points_for_last_event, default: false, null: false
      t.string :name, default: "New Calculation", required: true, unique: true
      t.string :points_for_place, array: true, default: [].to_yaml
      t.timestamps
    end
  end
end
