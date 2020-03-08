class AddOrderPersonLicense < ActiveRecord::Migration[5.2]
  def change
    add_column :order_people, :usac_license, :string, default: nil, null: true
  end
end
