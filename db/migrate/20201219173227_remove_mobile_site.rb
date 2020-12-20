class RemoveMobileSite < ActiveRecord::Migration[6.0]
  def change
    remove_column :racing_associations, :mobile_site, :boolean, default: false, null: false
  end
end
