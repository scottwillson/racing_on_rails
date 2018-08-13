# frozen_string_literal: true

module RacingOnRails
  module VestalVersions
    module Versioned
      extend ActiveSupport::Concern

      included do
        # Record (usually Person but can be ImportFile, Event, etc.) about to make this update.
        # Need separate attribute from updated_by to differentiate from previous, stored updated_by and new updated_by.
        attr_accessor :updater

        versioned except: %i[
                             created_by_paper_trail_id
                             created_by_paper_trail_name
                             created_by_paper_trail_type
                             current_login_at
                             current_login_ip
                             last_login_at
                             last_login_ip
                             login_count
                             password_salt
                             perishable_token
                             persistence_token
                             single_access_token
                             updated_by_paper_trail_id
                             updated_by_paper_trail_name
                             updated_by_paper_trail_type
                           ],
                  initial_version: true

        before_save :set_updated_by
      end

      def created_by
        versions.first.try :user
      end

      def updated_by_person
        versions.last.try :user
      end

      def set_updated_by
        if updater
          self.updated_by = updater
        elsif ::Person.current
          self.updated_by = ::Person.current
        end

        true
      end

      def updated_by_record
        updated_by if updated_by.is_a?(ActiveRecord::Base)
      end

      def updated_by_person_name
        case updated_by_person
        when nil
          ""
        when String
          updated_by_person
        else
          updated_by_person.name
        end
      end

      def created_from_result?
        created_by&.is_a? ::Event
      end

      def updated_after_created?
        created_at && updated_at && ((updated_at - created_at) > 1.hour)
      end

      def never_updated?
        !updated_after_created?
      end
    end
  end
end
