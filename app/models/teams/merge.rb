# frozen_string_literal: true

module Teams
  module Merge
    extend ActiveSupport::Concern

    # Callback
    def before_merge(_other_team)
      true
    end

    # Moves another Team's aliases, results, and people to this Team,
    # and delete the other Team.
    # Also adds the other Team's name as a new alias
    def merge(team)
      raise(ArgumentError, "Cannot merge nil team") unless team
      return false if team == self

      Team.transaction do
        team = Team.includes(:aliases, :people, :results).find(team.id)
        before_merge team

        team.create_team_for_historical_results!

        team.event_teams.each do |event_team|
          event_team.event_team_memberships.each do |event_team_membership|
            new_event_team = EventTeam.where(event: event_team.event, team: self).first_or_create!
            event_team_membership.event_team = new_event_team
            event_team_membership.save!
          end
          event_team.reload.destroy!
        end

        aliases << team.aliases
        events << team.events
        results << team.results
        people << team.people

        Team.delete team.id

        if !Alias.where(name: team.name, aliasable_type: "Team").where.not(aliasable_id: nil).exists? && !Team.exists?(name: team.name)
          aliases.create! name: team.name
        end
      end
    end

    # Preserve team names in old results by creating a new Team for them, and moving the results.
    #
    # Results are preserved by creating a new Team from the most recent Name. If a Team
    # already exists with the Name's name, results will move to existing Team.
    # This may be unxpected, can't think of a better way to handle it in this model.
    def create_team_for_historical_results!
      name = names.sort_by(&:year).reverse!.first

      if name
        team = Team.find_or_create_by(name: name.name)
        results.each do |r|
          team.results << r if r.date.year <= name.year
        end

        name.destroy
        names.each do |n|
          team.names << n unless name == n
        end
      end
    end
  end
end
