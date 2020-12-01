# frozen_string_literal: true

module People
  module Merge
    extend ActiveSupport::Concern

    MERGE_ATTRIBUTES = %i[
      billing_city
      billing_country_code
      billing_first_name
      billing_last_name
      billing_state
      billing_street
      billing_zip
      bmx_category
      card_expires_on
      card_printed_at
      ccx_category
      ccx_only
      cell_fax
      city
      club_name
      country_code
      date_of_birth
      dh_category
      email
      emergency_contact
      emergency_contact_phone
      fabric_road_numbers
      gender
      home_phone
      license
      license_expiration_date
      license_type
      membership_card
      member_usac_to
      mtb_category
      ncca_club_name
      non_member_result_id
      notes
      occupation
      official
      road_category
      status
      state
      street
      team_id
      track_category
      usac_license
      work_phone
      zip
    ].freeze

    # Moves another people' aliases, results, and race numbers to this person,
    # and delete the other person.
    # Also adds the other people' name as a new alias
    def merge(other_person, force: false)
      # Consider just using straight SQL for this --
      # it's not complicated, and the current process generates an
      # enormous amount of SQL

      ActiveSupport::Notifications.instrument(
        "merge.people.admin.racing_on_rails",
        person_id: id,
        person_name: name,
        other_id: other_person.try(:id),
        other_name: other_person.try(:name)
      ) do
        unless merge?(other_person, force: force)
          ActiveSupport::Notifications.instrument(
            "failure.merge.people.admin.racing_on_rails",
            person_id: id,
            person_name: name,
            other_id: other_person.try(:id),
            other_name: other_person.try(:name)
          )
          return false
        end

        Person.transaction do
          before_merge other_person

          if login.blank? && other_person.login.present?
            self.login = other_person.login
            self.crypted_password = other_person.crypted_password
            PaperTrail.request(enabled: false) do
              other_person.update login: nil
            end
          end
          self.member_from = other_person.member_from if member_from.nil? || (other_person.member_from && other_person.member_from < member_from)
          self.member_to = other_person.member_to if member_to.nil? || (other_person.member_to && other_person.member_to > member_to)

          other_person_is_newer = other_person.created_at > created_at
          MERGE_ATTRIBUTES.each do |attribute|
            send("#{attribute}=", other_person.send(attribute)) if other_person.send(attribute).present? && (send(attribute).blank? || other_person_is_newer)
          end

          if date_of_birth && other_person.date_of_birth && date_of_birth.day == 1
            self.date_of_birth = Time.zone.local(date_of_birth.year, date_of_birth.month, other_person.date_of_birth.day)
          end

          # Prevent unique index collision
          other_person.update_column :license, nil

          save!

          # save! can trigger automatic deletion for people created for old orders
          # if that happens, don't try and merge associations
          return true unless Person.exists?(id)

          aliases << other_person.aliases
          editor_requests << other_person.editor_requests
          editors << (other_person.editors - editors).uniq.reject { |e| e == self }
          events << other_person.events
          event_teams = event_team_memberships.map(&:event_team_id)
          event_team_memberships << other_person.event_team_memberships.reject { |e| event_teams.include?(e.event_team_id) }
          names << other_person.names
          race_numbers << other_person.race_numbers
          results << other_person.results
          versions << other_person.versions

          other_person.event_team_memberships.reload.clear
          Person.delete other_person.id
          existing_alias = aliases.detect { |a| a.name.casecmp(other_person.name) == 0 }
          aliases.create(name: other_person.name) if existing_alias.nil? && Person.find_all_by_name(other_person.name).empty?
        end
      end

      ActiveSupport::Notifications.instrument(
        "success.merge.people.admin.racing_on_rails",
        person_id: id,
        person_name: name,
        other_id: other_person.try(:id),
        other_name: other_person.try(:name)
      )

      true
    end

    def merge?(other_person, force: false)
      return false if other_person.nil? || other_person == self

      return true if force

      !other_people_with_same_name? && !other_person.other_people_with_same_name?
    end

    # Callback
    def before_merge(_other_person)
      true
    end
  end
end
