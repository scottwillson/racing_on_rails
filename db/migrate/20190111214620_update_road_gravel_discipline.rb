class UpdateRoadGravelDiscipline < ActiveRecord::Migration[5.2]
  def change
    Discipline.where(name: "Road/Gravel").update_all(name: "Gravel")
    Event.where(discipline: "Road/Gravel").update_all(discipline: "Gravel")
  end
end
