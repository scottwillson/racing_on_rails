class AddNumberIssuerToEvents < ActiveRecord::Migration
  def self.up
    add_column(:events, :number_issuer_id, :integer)
    add_index(:events, :number_issuer_id)
    add_foreign_key(:events, :number_issuer_id, :number_issuers, :id, :on_delete => :restrict)
  end

  def self.down
    remove_foreign_key(:events, :number_issuer_id, :number_issuers)
    remove_index(:events, :number_issuer_id)
    drop_column(:events, :number_issuer_id)
  end
end
