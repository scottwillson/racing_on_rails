class EnlargeOrderErrorMessage < ActiveRecord::Migration
  def change
    change_column :orders, :error_message, :string, limit: 2048
  end
end
