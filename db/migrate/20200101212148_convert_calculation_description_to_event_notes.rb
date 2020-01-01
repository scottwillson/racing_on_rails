class ConvertCalculationDescriptionToEventNotes < ActiveRecord::Migration[5.2]
  def change
    remove_column :calculations, :description, :string, null: false, default: ""
    add_column :calculations, :event_notes, :text, null: false, default: ""
  end
end
