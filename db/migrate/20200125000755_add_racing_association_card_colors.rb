class AddRacingAssociationCardColors < ActiveRecord::Migration[5.2]
  def change
    add_column :racing_associations, :card_background_color, :string, null: false, default: "000000"
    add_column :racing_associations, :card_text_color, :string, null: false, default: "ffffff"
  end
end
