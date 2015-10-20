class AddRacingAssociationPaymentGateway < ActiveRecord::Migration
  def change
    add_column :racing_associations, :default_payment_gateway_name, :string, null: true, default: "elavon"

    if RacingAssociation.current.short_name != "OBRA"
      racing_association = RacingAssociation.current
      racing_association.default_payment_gateway_name = nil
      racing_association.save!
    end
  end
end
