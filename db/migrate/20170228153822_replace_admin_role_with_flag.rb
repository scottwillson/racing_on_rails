# frozen_string_literal: true

class ReplaceAdminRoleWithFlag < ActiveRecord::Migration
  class Person < ApplicationRecord
    has_and_belongs_to_many :roles
  end

  class Role < ApplicationRecord
  end

  def up
    begin
      add_column(:people, :administrator, :boolean, default: false, null: false)
    rescue StandardError
      nil
    end

    Person.reset_column_information
    transaction do
      Person.includes(:roles).where("roles.name" => "Administrator").each do |person|
        person.update! administrator: true
      end
    end

    drop_table :people_roles
    drop_table :roles
  end

  def down
    create_table "roles", force: :cascade do |t|
      t.string   "name", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "people_roles", id: false, force: :cascade do |t|
      t.integer "role_id",   limit: 4, null: false
      t.integer "person_id", limit: 4, null: false
    end

    Person.reset_column_information
    transaction do
      administrator = Role.create!(name: "Administrator")
      Person.where(administrator: true).each do |person|
        person.roles << administrator
      end
    end

    drop_column :people, :administrator
  end
end
