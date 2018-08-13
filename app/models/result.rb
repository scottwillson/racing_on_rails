# frozen_string_literal: true

# Race result
#
# Race is the only required attribute -- even +person+ and +place+ can be blank
#
# Result keeps its own copy of +number+ and +team+, even though each Person has
# a +team+ atribute and many RaceNumbers. Result's number is just a String, not
# a RaceNumber
class Result < ActiveRecord::Base
  before_save :set_associated_records

  include Results::Caching
  include Results::Cleanup
  include Results::Comparison
  include Results::Competitions
  include Results::CustomAttributes
  include Results::People
  include Results::Times
  include Export::Results

  after_destroy :destroy_teams

  belongs_to :category
  belongs_to :event
  belongs_to :race
  belongs_to :team

  validates :race, presence: true

  scope :person_event, lambda { |person, event|
    includes(scores: %i[source_result competition_result])
      .where(event: event)
      .where(person: person)
  }

  scope :team_event, lambda { |team, event|
    includes(scores: %i[source_result competition_result])
      .where("results.event_id" => event.id)
      .where(team_id: team.id)
  }

  attr_accessor :updater

  # Replace any new +person+, or +team+ with one that already exists if name matches
  # TODO rationalize names
  def set_associated_records
    return true if competition_result?

    set_person
    update_membership
    set_team

    true
  end

  def set_team
    if team&.new_record?
      team.updater = event
      if team.name.blank?
        self.team = nil
      else
        existing_team = Team.find_by_name_or_alias(team.name)
        self.team = existing_team if existing_team
      end
    end
  end

  # Destroy Team that only exist because they were created by importing results
  def destroy_teams
    team.destroy if team&.no_results? && team.no_people? && team.created_from_result? && team.never_updated?
  end

  def category_name=(name)
    self.category = if name.blank?
                      nil
                    else
                      Category.find_or_create_by_normalized_name(name)
                    end
    self[:category_name] = name.try(:to_s)
  end

  def team_size
    @team_size ||= if race_id
                     Result.where(race_id: race_id, place: place).count
                   else
                     1
                   end
  end

  # Not blank, DNF, DNS, DQ.
  def finished?
    return false if place.blank?
    return false if %w[DNF DNS DQ].include?(place)
    numeric_place?
  end

  def finished_time_trial?
    numeric_place? && time && time > 0
  end

  # Does this result belong to the last event in a MultiDayEvent?
  def last_event?
    return false unless event&.parent
    return false unless event.parent.respond_to?(:parent)
    return true unless event.parent

    !(event.parent && (event.parent.end_date != date))
  end

  def date
    self[:date] || race.try(:date)
  end

  def distance
    self[:distance] || race&.distance
  end

  def event_id
    self[:event_id] || (race || race(true)).try(:event_id)
  end

  def event(reload = false)
    race.event(reload) if race(reload)
  end

  def laps
    self[:laps] || (race&.laps)
  end

  def place
    self[:place] || ""
  end

  def points
    if self[:points]
      self[:points].to_f
    else
      0.0
    end
  end

  # Hot spots
  def points_bonus_penalty=(value)
    value = 0 if value.nil? || value == ""
    self[:points_bonus_penalty] = value
  end

  # Points from placing at finish, not from hot spots
  def points_from_place=(value)
    value = 0 if value.nil? || value == ""
    self[:points_from_place] = value
  end

  # Person's current team name
  def person_team_name
    if person
      person.team_name
    else
      ""
    end
  end

  def team_name=(value)
    team_id_will_change!
    self.team = Team.new(name: value) if team.nil? || team.name != value
    person.team = team if person && person.team_name != value
    self[:team_name] = value
  end

  def member_result?
    (person_id.nil? || (person_id && person.member?(date))) && every_person_is_a_member?
  end

  def every_person_is_a_member?
    return true if RacingAssociation.current.exempt_team_categories.nil? || RacingAssociation.current.exempt_team_categories.include?(race.category.name)

    Result.where(race_id: race_id, place: place).where.not(id: id).find_each do |result|
      next unless result.person_id && !result.person.member?(date)
      # bad side effect
      update_attributes members_only_place: ""
      return false
    end

    true
  end

  def rental_number?
    RaceNumber.rental? number, Discipline[event.discipline]
  end

  def numeric_place?
    place && place.to_i > 0
  end

  def numeric_place
    if numeric_place?
      place.to_i
    else
      0
    end
  end

  def next_place
    if numeric_place?
      numeric_place + 1
    else
      place
    end
  end

  def inspect_debug
    puts "    #{to_long_s}"
    scores(true).sort.each do |score|
      puts "      #{score.inspect_debug}"
    end
  end

  # Add +race+ and +race#event+ name, time and points to default to_s
  def to_long_s
    "#<Result #{id}\t#{place}\t#{race.event.name}\t#{race.name} (#{race.id})\t#{name}\t#{team_name}\t#{category_name}\t#{points}\t#{time_s if self[:time]}>"
  end

  def to_s
    "#<Result #{id} place #{place} race #{race_id} person #{person_id} team #{team_id} pts #{points}>"
  end
end
