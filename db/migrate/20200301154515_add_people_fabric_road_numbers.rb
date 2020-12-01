# frozen_string_literal: true

class AddPeopleFabricRoadNumbers < ActiveRecord::Migration[5.2]
  def change
    change_table :people do |t|
      t.boolean :fabric_road_numbers, default: true, null: false
    end
  end
end
