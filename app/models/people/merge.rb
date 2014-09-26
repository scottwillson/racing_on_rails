module People
  module Merge
    extend ActiveSupport::Concern

  # Moves another people' aliases, results, and race numbers to this person,
  # and delete the other person.
  # Also adds the other people' name as a new alias
  def merge(other_person)
    # Consider just using straight SQL for this --
    # it's not complicated, and the current process generates an
    # enormous amount of SQL

    if other_person.nil? || other_person == self
      return false
    end

    Person.transaction do
      self.merge_version do
        other_person.results.collect do |result|
          event = result.event
          event
        end.compact || []
        if login.blank? && other_person.login.present?
          self.login = other_person.login
          self.crypted_password = other_person.crypted_password
          other_person.skip_version do
            other_person.update login: nil
          end
        end
        if member_from.nil? || (other_person.member_from && other_person.member_from < member_from)
          self.member_from = other_person.member_from
        end
        if member_to.nil? || (other_person.member_to && other_person.member_to > member_to)
          self.member_to = other_person.member_to
        end

        if license.blank?
          self.license = other_person.license
        end

        save!
        aliases << other_person.aliases
        events << other_person.events
        names << other_person.names
        results << other_person.results
        race_numbers << other_person.race_numbers

        begin
          versions << other_person.versions
        rescue ActiveRecord::SerializationTypeMismatch => e
          logger.error e
        end

        versions.sort_by(&:created_at).each_with_index do |version, index|
          version.number = index + 2
          version.save!
        end

        Person.delete other_person.id
        existing_alias = aliases.detect{ |a| a.name.casecmp(other_person.name) == 0 }
        if existing_alias.nil? and Person.find_all_by_name(other_person.name).empty?
          aliases.create(name: other_person.name)
        end
      end
    end
    true
  end
  end
end
