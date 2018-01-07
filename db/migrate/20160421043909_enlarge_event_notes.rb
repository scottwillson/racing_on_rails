# frozen_string_literal: true

class EnlargeEventNotes < ActiveRecord::Migration
  def change
    change_column :events, :notes, :text, limit: 65_535, default: nil
  end
end
