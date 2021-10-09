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

        create_names_for_historical_results!(team)
        self.member_from = team.member_from if member_from.nil? || (team.member_from && team.member_from < member_from)
        self.member_to = team.member_to if member_to.nil? || (team.member_to && team.member_to > member_to)

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
        names << team.names
        results << team.results
        people << team.people
        versions << team.versions

        Team.delete team.id

        if !Alias.where(name: team.name, aliasable_type: "Team").where.not(aliasable_id: nil).exists? && !Team.exists?(name: team.name)
          aliases.create! name: team.name
        end
      end
    end

    # Preserve team names in old results
    def create_names_for_historical_results!(other_team)
      other_team.results.pluck(:year).uniq
                .reject { |year| year == RacingAssociation.current.year }
                .each do |year|
        year_name = names.find_by(year: year)&.name
        other_team_year_name = other_team.names.find_by(year: year)&.name
        if other_team_year_name != name && !year_name
          names.create!(name: other_team_year_name, year: year)
        end
      end
    end
  end
end
