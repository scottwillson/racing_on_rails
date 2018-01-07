# frozen_string_literal: true

class AddCategoriesAbility < ActiveRecord::Migration
  def change
    add_column(:categories, :ability, :integer, default: 0, null: false)
  rescue StandardError
    nil
  end
end
