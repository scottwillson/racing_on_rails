# frozen_string_literal: true

class Calculations::V3::Discipline < ApplicationRecord
  self.table_name = "calculations_disciplines"

  belongs_to :calculation
  belongs_to :discipline, class_name: "::Discipline"

  validates :discipline, uniqueness: { scope: :calculation }
end
