class EnlargePaymentGatewayMessage < ActiveRecord::Migration
  def up
    change_column :payment_gateway_transactions, :message, :text
  end

  def down
    change_column :payment_gateway_transactions, :message, :string
  end
end
