# frozen_string_literal: true

class CreateCalculationsCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :calculations_categories, id: false do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.belongs_to :calculation, index: true
      t.belongs_to :category, index: true
    end
  end
end
