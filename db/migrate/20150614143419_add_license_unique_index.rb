class AddLicenseUniqueIndex < ActiveRecord::Migration
  def change
    change_column :people, :license, :string, default: nil, null: true
    remove_index(:people, name: :index_people_on_license) rescue nil
    add_index :people, :license, unique: true
  end
end
