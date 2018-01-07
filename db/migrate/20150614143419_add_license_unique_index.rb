# frozen_string_literal: true

class AddLicenseUniqueIndex < ActiveRecord::Migration
  def change
    change_column :people, :license, :string, default: nil, null: true
    begin
      remove_index(:people, name: :index_people_on_license)
    rescue StandardError
      nil
    end
    add_index :people, :license, unique: true
  end
end
