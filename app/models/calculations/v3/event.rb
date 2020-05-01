# frozen_string_literal: true

class Calculations::V3::Event < ApplicationRecord
  self.table_name = "calculations_events"

  belongs_to :calculation
  belongs_to :event, class_name: "::Event"
end
