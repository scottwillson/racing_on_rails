# frozen_string_literal: true

module Events
  module Defaults
    extend ActiveSupport::Concern

    included do
      after_initialize :set_defaults
    end

    # Defaults state to RacingAssociation.current.state, date to today, name to New Event mm-dd-yyyy
    # NumberIssuer: RacingAssociation.current.short_name
    # Child events use their parent's values unless explicity overriden. And you cannot override
    # parent values by passing in blank or nil attributes to initialize, as there is
    # no way to differentiate missing values from nils or blanks.
    def set_defaults
      if new_record?
        set_propogated_attributes
        self.bar_points = default_bar_points       if self[:bar_points].nil?
        self.date = default_date                   if self[:date].nil?
        self.discipline = default_discipline       if self[:discipline].nil?
        self.name = default_name                   if self[:name].nil?
        self.ironman = default_ironman             if self[:ironman].nil?
        self.number_issuer = default_number_issuer if number_issuer.nil?
        self.region_id = default_region_id         if self[:region_id].nil?
        self.sanctioned_by = default_sanctioned_by if (parent.nil? && self[:sanctioned_by].nil?) || (parent && parent[:sanctioned_by].nil?)
        self.state = default_state                 if (parent.nil? && self[:state].nil?) || (parent && parent[:state].nil?)
      end
    end

    def set_propogated_attributes
      if parent
        propogated_attributes.each do |attr|
          self[attr] = parent[attr] if self[attr].blank?
        end
      end
    end

    def propogated_attributes
      @propogated_attributes ||= %w[
        beginner_friendly
        canceled
        city
        discipline
        email
        flyer
        flyer_approved
        instructional
        name
        number_issuer_id
        phone
        postponed
        practice
        prize_list
        promoter_id
        sanctioned_by
        sanctioned_by
        state
        team_id
        tentative
        time
        time
        velodrome_id
      ]
    end

    def attributes_for_duplication
      allowed_attributes = attributes.dup
      allowed_attributes.delete "atra_points_series"
      allowed_attributes.delete "bar_points"
      allowed_attributes.delete "created_at"
      allowed_attributes.delete "created_by_id"
      allowed_attributes.delete "created_by_name"
      allowed_attributes.delete "created_by_type"
      allowed_attributes.delete "id"
      allowed_attributes.delete "ironman"
      allowed_attributes.delete "slug"
      allowed_attributes.delete "updated_at"
      allowed_attributes.delete "updated_by_id"
      allowed_attributes.delete "updated_by_name"
      allowed_attributes.delete "updated_by_type"
      allowed_attributes.delete "year"
      allowed_attributes
    end

    def default_bar_points
      if parent.is_a?(WeeklySeries) || (parent.try(:parent) && parent.parent.is_a?(WeeklySeries))
        0
      else
        1
      end
    end

    def default_discipline
      "Road"
    end

    def default_ironman
      true
    end

    def default_region_id
      RacingAssociation.current.default_region_id
    end

    def default_state
      RacingAssociation.current.state
    end

    def default_sanctioned_by
      RacingAssociation.current.default_sanctioned_by
    end

    def default_number_issuer
      NumberIssuer.find_by(name: RacingAssociation.current.short_name)
    end
  end
end
