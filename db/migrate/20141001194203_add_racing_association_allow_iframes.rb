class AddRacingAssociationAllowIframes < ActiveRecord::Migration
  def change
    add_column :racing_associations, :allow_iframes, :boolean, default: false
  end
end
