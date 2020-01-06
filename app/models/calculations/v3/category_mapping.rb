# frozen_string_literal: true

class Calculations::V3::CategoryMapping < ApplicationRecord
  self.table_name = "calculations_categories_mappings"

  validates :calculation_category, presence: true
  validates :category, presence: true

  belongs_to :calculation_category, class_name: "Calculations::V3::Category", inverse_of: :mappings
  belongs_to :category, class_name: "::Category", inverse_of: :calculation_category_mappings
  belongs_to :discipline, class_name: "::Discipline", inverse_of: :calculation_category_mappings
end
