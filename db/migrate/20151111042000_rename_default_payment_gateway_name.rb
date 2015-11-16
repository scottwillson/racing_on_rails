class RenameDefaultPaymentGatewayName < ActiveRecord::Migration
  def change
    rename_column :racing_associations, :default_payment_gateway_name, :payment_gateway_name
  end
end
