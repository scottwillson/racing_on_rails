class AddUsacLicense < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :usac_license, :string, default: nil, null: true
    add_index :people, :usac_license
  end
end
