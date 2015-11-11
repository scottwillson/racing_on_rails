class AddOrderGateway < ActiveRecord::Migration
  def change
    add_column :orders, :gateway, :string, null: true, default: nil
    add_index :orders, :gateway

    if defined?(Order)
      Order.purchased.update_all gateway: "elavon"
    end
  end
end
