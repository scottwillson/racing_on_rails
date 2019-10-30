class AddLicenseIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :people, :license
  end
end
