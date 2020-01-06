# frozen_string_literal: true

class Calculations::V3::Category < ApplicationRecord
  self.table_name = "calculations_categories"

  belongs_to :calculation
  belongs_to :category, class_name: "::Category"
  has_many :mappings,
           class_name: "Calculations::V3::CategoryMapping",
           dependent: :destroy,
           foreign_key: :calculation_category_id,
           inverse_of: :calculation_category

  has_many :mapped_categories, through: :mappings, class_name: "::Category"

  delegate :name, to: :category
end
