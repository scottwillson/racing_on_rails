class CreateCalculationsRejectedCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :calculations_rejected_categories, id: false, force: true do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.belongs_to :calculation, index: true
      t.belongs_to :category, index: true
    end
  end
end
