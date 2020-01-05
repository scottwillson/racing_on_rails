# frozen_string_literal: true

class Calculations::V3::Category < ApplicationRecord
  self.table_name = "calculations_categories"

  belongs_to :calculation
  belongs_to :category, class_name: "::Category"
  has_and_belongs_to_many :matches, class_name: "::Category" # rubocop:disable Rails/HasAndBelongsToMany

  delegate :name, to: :category
end
