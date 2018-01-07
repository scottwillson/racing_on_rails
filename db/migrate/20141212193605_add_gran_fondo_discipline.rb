# frozen_string_literal: true

class AddGranFondoDiscipline < ActiveRecord::Migration
  def up
    Discipline.create!(name: "Gran Fondo") if RacingAssociation.current.short_name == "OBRA"
  end

  def down
    Discipline.where(name: "Gran Fondo").destroy_all
  end
end
