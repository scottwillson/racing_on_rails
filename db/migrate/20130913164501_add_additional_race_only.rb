class AddAdditionalRaceOnly < ActiveRecord::Migration
  def up
    if RacingAssociation.current.short_name == "OBRA" || RacingAssociation.current.short_name == "NABRA"
      add_column :races, :additional_race_only, :boolean, default: false, null: false
    end
  end

  def down
    if RacingAssociation.current.short_name == "OBRA" || RacingAssociation.current.short_name == "NABRA"
      remove_column :races, :additional_race_only
    end
  end
end