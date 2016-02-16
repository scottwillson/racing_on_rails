class UpdateObracxCats < ActiveRecord::Migration
  def change
    if RacingAssociation.current.short_name == "OBRA"
      Person.where(ccx_category: "A").update_all(ccx_category: 1)
      Person.where(ccx_category: "B").update_all(ccx_category: 2)
      Person.where(ccx_category: "C").update_all(ccx_category: 3)
      Person.where(ccx_category: "Beginner").update_all(ccx_category: 4)
    end
  end
end
