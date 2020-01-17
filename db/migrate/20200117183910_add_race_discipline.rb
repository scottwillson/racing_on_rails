# frozen_string_literal: true

class AddRaceDiscipline < ActiveRecord::Migration[5.2]
  def change
    change_table :races do |t|
      t.belongs_to :discipline, foreign_key: true, type: :integer
    end
  end
end
