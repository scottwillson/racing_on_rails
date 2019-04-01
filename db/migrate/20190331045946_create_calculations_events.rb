class CreateCalculationsEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :calculations_events do |t|
      t.belongs_to :calculation, index: true
      t.belongs_to :event, index: true
      t.float :multiplier, default: 1.0, null: false
      t.timestamps
    end
  end
end
