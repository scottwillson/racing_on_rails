class RenameOjcs < ActiveRecord::Migration
  def change
    Event
      .where(type: "Competitions::OregonJuniorCyclocrossSeries")
      .update_all(type: "Competitions::OregonJuniorCyclocrossSeries::Overall")
  end
end
