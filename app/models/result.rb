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

  validates_presence_of :race

  scope :person_event, lambda { |person, event|
    includes(scores: [ :source_result, :competition_result ]).
    where(event: event).
    where(person: person)
  }

  scope :team_event, lambda { |team, event|
    includes(scores: [ :source_result, :competition_result ]).
    where("results.event_id" => event.id).
    where(team_id: team.id)
  }

  attr_accessor :updated_by

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
    if team && team.new_record?
      team.updated_by = event
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
    if team && team.results.count == 0 && team.people.count == 0 && team.created_from_result? && !team.updated_after_created?
      team.destroy
    end
  end

  def category_name=(name)
    if name.blank?
      self.category = nil
    else
      self.category = Category.find_or_create_by_normalized_name(name)
    end
    self[:category_name] = name.try(:to_s)
  end

  def team_size
    if race_id
      @team_size ||= Result.where(race_id: race_id, place: place).count
    else
      @team_size ||= 1
    end
  end

  # Not blank, DNF, DNS, DQ.
  def finished?
    return false if place.blank?
    return false if ["DNF", "DNS", "DQ"].include?(place)
    numeric_place?
  end

  def finished_time_trial?
    numeric_place? && time && time > 0
  end

  # Does this result belong to the last event in a MultiDayEvent?
  def last_event?
    return false unless self.event && event.parent
    return false unless event.parent.respond_to?(:parent)
    return true unless event.parent

    !(event.parent && (event.parent.end_date != self.date))
  end

  def date
    self[:date] || race.try(:date)
  end

  def distance
    race && race.distance
  end

  def event_id
    self[:event_id] || (race || race(true)).try(:event_id)
  end

  def event(reload = false)
    if race(reload)
      race.event(reload)
    end
  end

  def laps
    self[:laps] || (race && race.laps)
  end

  def place
    self[:place] || ''
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
    if value == nil || value == ""
      value = 0
    end
    write_attribute(:points_bonus_penalty, value)
  end

  # Points from placing at finish, not from hot spots
  def points_from_place=(value)
    if value == nil || value == ""
      value = 0
    end
    write_attribute(:points_from_place, value)
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
    if team.nil? || team.name != value
      self.team = Team.new(name: value)
    end
    if person && person.team_name != value
      person.team = team
    end
    self[:team_name] = value
  end

  def member_result?
    (person_id.nil? || (person_id && person.member?(date))) && !non_members_on_team?
  end

  def non_members_on_team?
    exempt_cats = RacingAssociation.current.exempt_team_categories
    if exempt_cats.nil? || exempt_cats.include?(race.category.name)
      return false
    end

    non_members = false

    other_results_in_place = Result.where(race_id: race_id, place: place)
    other_results_in_place.each do |result|
      unless result.person.nil?
        if !result.person.member?(date)
          self.update_attributes members_only_place: ""
          non_members = true
        end
      end
    end

    non_members
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
    puts to_long_s
    scores(true).sort.each do |score|
      puts score.inspect_debug
    end
  end

  # Add +race+ and +race#event+ name, time and points to default to_s
  def to_long_s
    "#<Result #{id}\t#{place}\t#{race.event.name}\t#{race.name} (#{race.id})\t#{name}\t#{team_name}\t#{self.category_name}\t#{points}\t#{time_s if self[:time]}>"
  end

  def to_s
    "#<Result #{id} place #{place} race #{race_id} person #{person_id} team #{team_id} pts #{points}>"
  end
end
