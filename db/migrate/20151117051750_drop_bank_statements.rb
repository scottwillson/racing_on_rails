class DropBankStatements < ActiveRecord::Migration
  def change
    drop_table :bank_statements
  end
end
