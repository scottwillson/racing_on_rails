class AddOrderGateway < ActiveRecord::Migration
  def change
    add_column :orders, :gateway, :string, null: true, default: nil
    add_index :orders, :gateway

    if RacingAssociation.current.short_name != "OBRA"
      Order.where(gateway: nil).purchased.update_all gateway: "elavon"
    end
  end
end
