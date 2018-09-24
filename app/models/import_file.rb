# frozen_string_literal: true

# audit of source file for results and membership uploads
class ImportFile < ApplicationRecord
  validates :name, presence: true
end
