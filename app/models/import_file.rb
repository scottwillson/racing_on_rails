# frozen_string_literal: true

# audit of source file for results and membership uploads
class ImportFile < ActiveRecord::Base
  validates :name, presence: true
end
