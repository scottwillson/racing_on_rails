# frozen_string_literal: true

# Bike racing team of People
#
# Like People, Teams may have many alternate names. These are modelled as Aliases. Historical names from previous years are stored as Names.
#
# Team names must be unique
class Team < ApplicationRecord
  include Export::Teams
  include Teams::Merge
  include Names::Nameable
  include RacingOnRails::PaperTrail::Versions
  include Teams::Membership

  before_save :destroy_shadowed_aliases
  around_save :add_alias_for_old_name
  before_destroy :ensure_no_results

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  has_many :aliases, as: :aliasable, dependent: :destroy
  has_many :events
  has_many :event_teams
  has_many :people
  has_many :results

  def self.find_by_name_or_alias(name)
    Team.find_by(name: name) || Alias.where(name: name, aliasable_type: "Team").first&.team
  end

  def self.find_by_name_or_alias_or_create(name)
    find_by_name_or_alias(name) || Team.create(name: name)
  end

  def self.name_like(name)
    name_like = "%#{name}%"
    Team
      .where("teams.name like ? or aliases.name like ?", name_like, name_like)
      .includes(:aliases)
      .references(:aliases)
      .order("teams.name")
  end

  def teams_with_same_name
    teams = Team.where(name: name) | Alias.find_all_teams_by_name(name)
    teams.reject { |team| team == self }
  end

  # For sorting
  def downcased_name
    name.downcase
  end

  def ensure_no_results
    unless no_results?
      errors.add :base, "Cannot delete team with results. #{name} has #{results.count} results."
      throw :abort
    end
  end

  def no_results?
    results.count == 0
  end

  def no_people?
    people.count == 0
  end

  # If name changes to match existing alias, destroy the alias
  def destroy_shadowed_aliases
    Alias.where(name: name).destroy_all
  end

  def add_alias_for_old_name
    previous_name = name_was

    yield

    if !new_record? &&
       previous_name.present? &&
       name.present? &&
       previous_name.casecmp(name) != 0 &&
       !Alias.exists?(name: previous_name, aliasable_id: id, aliasable_type: "Team") &&
       !Team.exists?(name: previous_name)

      new_alias = Alias.new(name: previous_name, team: self)
      unless new_alias.save
        errors :aliases, "Could not save alias #{new_alias}: #{new_alias.errors.full_messages.join(', ')}"
        throw :abort
      end
      new_alias
    end
  end

  def member_in_year?(_date)
    member?
  end

  def name=(value)
    self.name_was = name unless name_was
    self[:name] = value
  end

  def to_s
    "#<Team #{id} '#{name}'>"
  end
end
