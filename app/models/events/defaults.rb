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
        if parent
          propogated_attributes.each { |attr|
            (self[attr] = parent[attr]) if self[attr].blank?
          }
        end
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

    def propogated_attributes
      @propogated_attributes ||= %w{
        city discipline flyer name number_issuer_id promoter_id prize_list sanctioned_by state time velodrome_id time
        postponed cancelled flyer_approved instructional practice sanctioned_by email phone team_id beginner_friendly
      }
    end

    def attributes_for_duplication
      _attributes = attributes.dup
      _attributes.delete("id")
      _attributes.delete("created_at")
      _attributes.delete("updated_at")
      _attributes
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
      NumberIssuer.find_by_name(RacingAssociation.current.short_name)
    end
  end
end
