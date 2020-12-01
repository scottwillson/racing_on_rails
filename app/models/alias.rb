# frozen_string_literal: true

# Alternate name for a Person or Team. Example: Erik Tonkin might have aliases of 'Eric Tonkin,' and 'E. Tonkin'
# Must belong to either a Person or Team, but not both. Used by Result when importing results from Excel.
# Aliases cannot be the same ("shadow") as Person#name or Team#name.
# This could probably be combined with Name.
class Alias < ApplicationRecord
  include Export::Aliases
  belongs_to :aliasable, polymorphic: true

  validates :name, presence: true
  validate :cannot_shadow

  def self.find_all_people_by_name(name)
    Alias.includes(:aliasable).where("aliases.name" => name).where(aliasable_type: "Person").map(&:aliasable)
  end

  def self.find_all_teams_by_name(name)
    Alias.includes(:aliasable).where("aliases.name" => name).where(aliasable_type: "Team").map(&:aliasable)
  end

  def person
    aliasable
  end

  def person=(person)
    self.aliasable = person
  end

  def team
    aliasable
  end

  def team=(team)
    self.aliasable = team
  end

  def to_s
    "<#{self.class.name} #{self[:id]} #{self[:name]} #{self[:person_id]} #{self[:team_id]}>"
  end

  private

  def cannot_shadow
    if aliasable_id && aliasable_type.safe_constantize.exists?(name: name)
      errors.add :name, "#{aliasable_type} named '#{name}' already exists. Cannot create alias that shadows a real name."
    end
  end
end
