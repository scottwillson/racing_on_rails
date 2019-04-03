# frozen_string_literal: true

module Calculations::V3::CalculationConcerns::Dates
  extend ActiveSupport::Concern

  included do
    before_save :set_year
    validate :dates_are_same_year
    default_value_for(:year) {Time.zone.now.year}
  end

  def date
    event&.date || Time.zone.local(year).beginning_of_year
  end

  def dates_are_same_year
    errors.add(:date, "must be in year #{year}, but is #{date.year}") unless year == date.year
    errors.add(:end_date, "must be in year #{year}, but is #{end_date.year}") unless year == end_date.year

    if event && year != event.year
      errors.add(:event, "year #{event.year} must be same as year #{year}")
    end

    if source_event && year != source_event.year
      errors.add(:source_event, "year #{source_event.year} must be same as year #{year}")
    end
  end

  def end_date
    event&.end_date || Time.zone.local(year).end_of_year
  end

  def set_year
    if source_event
      self.year = source_event.year
    end
  end
end
