class AddOrderGateway < ActiveRecord::Migration
  def change
    add_column :orders, :gateway, :string, null: true, default: nil
    add_index :orders, :gateway
  end
end
