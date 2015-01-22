class AddGranFondoDiscipline < ActiveRecord::Migration
  def up
    if RacingAssociation.current.short_name == "OBRA"
      Discipline.create!(name: "Gran Fondo")
    end
  end

  def down
    Discipline.where(name: "Gran Fondo").destroy_all
  end
end
