class AddUniqueIndexes < ActiveRecord::Migration[6.0]
  def change
    remove_index :people, column: :license, name: :index_people_on_license
    remove_index :people, column: :login, name: :index_people_on_login
    remove_index :velodromes, column: :name, name: :index_velodromes_on_name

    execute "update people set login = null where login = ''"
    execute "update people set license = null where license = ''"

    add_index :people, :license, unique: true
    add_index :people, :login, unique: true

    Name.select(:name, :year, :nameable_type, :nameable_id).having("count(*) > 1").group("name, year, nameable_type, nameable_id").each do |name|
      Name.where(name: name.name, year: name.year, nameable_type: name.nameable_type, nameable_id: name.nameable_id).first.destroy!
    end

    Name.select(:name, :year, :nameable_type, :nameable_id).having("count(*) > 1").group("name, year, nameable_type, nameable_id").each do |name|
      Name.where(name: name.name, year: name.year, nameable_type: name.nameable_type, nameable_id: name.nameable_id).first.destroy!
    end

    Name.select(:year, :nameable_type, :nameable_id).having("count(*) > 1").group("year, nameable_type, nameable_id").each do |name|
      Name.where(year: name.year, nameable_type: name.nameable_type, nameable_id: name.nameable_id).first.destroy!
    end

    add_index :names, [:name, :year, :nameable_type, :nameable_id], unique: true
    add_index :names, [:nameable_id, :year, :nameable_type], unique: true
    add_index :velodromes, :name, unique: true
  end
end
