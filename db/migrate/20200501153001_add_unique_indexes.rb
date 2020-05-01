class AddUniqueIndexes < ActiveRecord::Migration[6.0]
  def change
    remove_index :people, name: :index_people_on_license
    remove_index :people, name: :index_people_on_login
    remove_index :velodromes, name: :index_velodromes_on_name

    add_index :people, :license, unique: true
    add_index :people, :login, unique: true
    add_index :names, [:name, :year, :nameable_type, :nameable_id], unique: true
    add_index :names, [:nameable_id, :year, :nameable_type], unique: true
    add_index :velodromes, :name, unique: true
  end
end
