# frozen_string_literal: true

class Calculations::V3::Category < ApplicationRecord
  self.table_name = "calculations_categories"

  belongs_to :calculation
  belongs_to :category
end
