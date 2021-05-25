# frozen_string_literal: true

# In-memory cache of Persons and Teams. Used when saving calculated Results.
module Calculations::V3::CalculationConcerns::Cache
  extend ActiveSupport::Concern

  def populate_source_result_category_names
    @category_names = {}
    ::Category.pluck(:id, :name).each do |id, name|
      @category_names[id] = name
    end

    @category_names
  end

  def populate_people(results)
    @people = {}

    people = ::Person
             .includes(team: :names)
             .includes(:names)
             .where(id: results.map(&:participant_id).uniq)

    people.find_each do |person|
      @people[person.id] = person
    end

    @people
  end

  def populate_teams(results)
    @teams = {}

    teams = ::Team
            .includes(:names)
            .where(id: results.map(&:participant_id).uniq)

    teams.find_each do |team|
      @teams[team.id] = team
    end

    @teams
  end

  def result_person_and_team(result)
    if team?
      [nil, team_for_id(result.participant_id)]
    else
      person = @people[result.participant_id]
      [person, person.team]
    end
  end

  def result_team(result)
    if team?
      return @teams[result.participant_id]
    end

    @people[result.participant_id].team
  end

  def result_team_id(result)
    if team?
      return result.participant_id
    end

    @people[result.participant_id].team_id
  end
end

# Can't shadow existing boolean 'team' attribute
def team_for_id(id)
  team = @teams[id]

  raise(ActiveRecord::RecordNotFound, "No team found for id #{id} in #{@teams.keys.sort}") unless team

  team
end
