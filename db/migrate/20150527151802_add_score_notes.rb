# frozen_string_literal: true

class AddScoreNotes < ActiveRecord::Migration
  def change
    add_column :scores, :notes, :string
  end
end
