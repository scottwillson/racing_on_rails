# frozen_string_literal: true

class CreateCalculations < ActiveRecord::Migration[5.2]
  def change
    create_table :calculations, force: true do |t|
      t.references :event
      t.references :source_event
      t.string :name, default: "New Calculation", required: true, unique: true
      t.timestamps
    end
  end
end
