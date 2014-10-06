module Results
  module People
    extend ActiveSupport::Concern

    included do
      after_save :update_person_number
      after_destroy :destroy_people

      belongs_to :person

      scope :person, lambda { |person|
        if person.is_a? Person
          person_id = person.id
        else
          person_id = person
        end

        includes(:team, :person, :scores, :category, { race: [ :event, :category ] }).
        where(person_id: person_id)
      }
    end

    def set_person
      if person && person.new_record?
        person.updated_by = event
        if person.name.blank?
          self.person = nil
        else
          existing_people = find_people
          if existing_people.size == 1
            self.person = existing_people.first
          elsif existing_people.size > 1
            self.person = Person.select_by_recent_activity(existing_people)
          end
        end
      end
    end

    # Use +first_name+, +last_name+, +race_number+, +team+ to figure out if +person+ already exists.
    # Returns an Array of People if there is more than one potential match
    #
    # Need Event to match on race number. Event will not be set before result is saved to database
    def find_people
      matches = Set.new

      matches = eager_find_person_by_license(matches)
      return matches if matches.size == 1

      matches = find_person_by_name(matches)
      return matches if matches.size == 1

      matches = find_person_by_number(matches)
      return matches if matches.size == 1

      matches = find_person_by_team_name(matches)
      return matches if matches.size == 1

      find_person_by_license(matches)
    end

    # license first if present and source is reliable (USAC)
    def eager_find_person_by_license(matches)
      if RacingAssociation.current.eager_match_on_license? && license.present?
        matches << Person.where(license: license).first
      end

      matches
    end

    def find_person_by_name(matches)
      matches + Person.find_all_by_name_or_alias(first_name: first_name, last_name: last_name)
    end

    def find_person_by_number(matches)
      if number.present?
        if matches.size > 1
          # use number to choose between same names
          RaceNumber.find_all_by_value_and_event(number, event).each do |race_number|
            if matches.include?(race_number.person)
              matches = Set.new ([ race_number.person ])
            end
          end
        elsif name.blank?
          # no name, so try to match by number
          matches = RaceNumber.find_all_by_value_and_event(number, event).map(&:person)
        end
      end

      matches
    end

    def find_person_by_team_name(matches)
      unless team_name.blank?
        team = Team.find_by_name_or_alias(team_name)
        matches.reject! do |match|
          match.team != team
        end
      end

      matches
    end

    def find_person_by_license(matches)
      unless self.license.blank?
        matches.reject! do |match|
          match.license != license
        end
      end

      matches
    end

    def update_membership
      if update_membership?
        person.updated_by = event
        person.member_from = race.date
      end
    end

    def update_membership?
      person &&
      RacingAssociation.current.add_members_from_results? &&
      person.new_record? &&
      person.first_name.present? &&
      person.last_name.present? &&
      person[:member_from].blank? &&
      event.association? &&
      !rental_number?
    end

    # Set +person#number+ to +number+ if this isn't a rental number
    def update_person_number
      return true if competition_result?

      if person &&
         event.number_issuer &&
         event.number_issuer != RacingAssociation.current.number_issuer &&
         number.present? &&
         !rental_number?

        person.updated_by = updated_by
        person.add_number number, Discipline[event.discipline], event.number_issuer, event.date.year
      end
    end

    # Destroy People that only exist because they were created by importing results
    def destroy_people
      if person && person.results.count == 0 && person.created_from_result? && !person.updated_after_created?
        person.destroy
      end
    end

    # Only used for manual entry of Cat 4 Womens Series Results
    def validate_person_name
      if first_name.blank? && last_name.blank?
        errors.add(:first_name, "and last name cannot both be blank")
      end
    end

    def first_name=(value)
      if self.person
        self.person.first_name = value
      else
        self.person = Person.new(first_name: value)
      end
      self[:first_name] = value
      self[:name] = self.person.try(:name, date)
    end

    def last_name=(value)
      if self.person
        self.person.last_name = value
      else
        self.person = Person.new(last_name: value)
      end
      self[:last_name] = value
      self[:name] = self.person.try(:name, date)
    end

    def person_name
      name
    end

    # person.name
    def name=(value)
      if value.present?
        if person.try(:name) != value
          self.person = Person.new(name: value)
        end
        self[:first_name] = person.first_name
        self[:last_name] = person.last_name
      else
        self.person = nil
        self[:first_name] = nil
        self[:last_name] = nil
      end
      self[:name] = value
    end

    def person_name=(value)
      self.name = value
    end
  end
end
