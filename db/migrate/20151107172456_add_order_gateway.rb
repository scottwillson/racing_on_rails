class AddOrderGateway < ActiveRecord::Migration
  def change
    add_column(:orders, :gateway, :string, null: true, default: nil) rescue nil
    add_index(:orders, :gateway) rescue nil

    if RacingAssociation.current.short_name == "NABRA"
      Order.where(gateway: nil).purchased.update_all gateway: "elavon"
    end
  end
end
