class SetMbraTeamsPreference < ActiveRecord::Migration
  def up
    if RacingAssociation.current.short_name == "mbra"
      mbra = RacingAssociation.current
      mbra.show_all_teams_on_public_page = false
      mbra.save!
    end
  end
end
