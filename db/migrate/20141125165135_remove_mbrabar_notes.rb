# frozen_string_literal: true

class RemoveMbrabarNotes < ActiveRecord::Migration
  def change
    bar = Competitions::MbraBar.current_year.first
    bar&.races&.map(&:results)&.flatten&.each do |result|
      result.update_attributes! notes: nil if result.notes.present?
    end
  end
end
