class SplitShowersPassTeams < ActiveRecord::Migration
  def change
    if RacingAssociation.current.short_name == "OBRA"
      Team.transaction do
        mtb_team = Team.where(id: 36326, name: "Showers Pass Ccx/Mtb Team").first!

        mtb_team.name = "Showers Pass CCX/MTB Team"
        mtb_team.member = true
        mtb_team.save!

        Person.where(team_id: 33718).select do |p|
          p.versions.any? do |v|
            v.modifications["team_id"] && v.modifications["team_id"].first == 2985
          end
        end.
        each do |person|
          say "Move #{person.name} to Showers Pass CCX/MTB Team"
          person.team_id = 36326
          person.save!

          person.results.where(year: 2015).each do |result|
            result.team_id = 36326
            result.save!
          end
        end
      end
    end
  end
end
