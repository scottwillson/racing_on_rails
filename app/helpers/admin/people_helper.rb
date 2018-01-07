# frozen_string_literal: true

module Admin::PeopleHelper
  # Escape for FinishLynx PPL files
  def ppl_escape(text)
    text&.gsub(",", '\""')
  end
end
