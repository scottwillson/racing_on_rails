# frozen_string_literal: true

class ResultSource < ApplicationRecord
  belongs_to :calculated_result, class_name: "Result"
  belongs_to :source_result, class_name: "Result"
end
