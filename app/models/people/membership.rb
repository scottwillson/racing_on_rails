module People
  module Membership
    extend ActiveSupport::Concern

    YEAR_1900 = Time.zone.local(1900).to_date

    # Is Person a current member of the bike racing association?
    def member?(date = Time.zone.today)
      member_to.present? && member_from.present? && member_from.to_date <= date.to_date && member_to.to_date >= date.to_date
    end

    # Is/was Person a current member of the bike racing association at any point during +date+'s year?
    def member_in_year?(date = Time.zone.today)
      year = date.year
      member_to && member_from && member_from.year <= year && member_to.year >= year
      member_to.present? && member_from.present? && member_from.year <= year && member_to.year >= year
    end

    def member
      member?
    end

    def member=(value)
      if value
        self.member_from = Time.zone.today if member_from.nil? || member_from.to_date >= Time.zone.today.to_date
        unless member_to && (member_to.to_date >= Time.zone.local(RacingAssociation.current.effective_year).end_of_year.to_date)
          self.member_to = Time.zone.local(RacingAssociation.current.effective_year).end_of_year.to_date
        end
      elsif !value && member?
        if self.member_from.year == RacingAssociation.current.year
          self.member_from = nil
          self.member_to = nil
        else
          self.member_to = Time.zone.local(RacingAssociation.current.year - 1).end_of_year.to_date
        end
      end
    end

    # Also sets member_to if it is blank
    def member_from=(date)
      if date.nil?
        self[:member_from] = nil
        self[:member_to] = nil
        return date
      end

      date_as_date = case date
      when Date, DateTime, Time
        Time.zone.local(date.year, date.month, date.day)
      else
        Time.zone.parse(date)
      end

      self[:member_from] = date_as_date
    end

    # Also sets member_from if it is blank
    def set_membership_dates
      if member_from && member_to.nil?
        self.member_to = Time.zone.local(member_from.year).end_of_year
      elsif member_from.nil? && member_to
        self.member_from = Time.zone.today if member_from.nil?
        self.member_from = member_to if member_from.to_date > member_to.to_date
      elsif member_from && member_to && member_from.to_date > member_to.to_date
        self.member_from = member_to
      end
      true
    end

    # Validates member_from and member_to
    def membership_dates
      if member_to && !member_from
        errors.add('member_from', "cannot be nil if member_to is not nil (#{member_to})")
      end
      if member_from && !member_to
        errors.add('member_to', "cannot be nil if member_from is not nil (#{member_from})")
      end
      if member_from && member_to && member_from.to_date > member_to.to_date
        errors.add('member_to', "cannot be greater than member_from: #{member_from}")
      end
      if member_from && member_from < YEAR_1900
        self.member_from = member_from_was
      end
      if member_to && member_to < YEAR_1900
        self.member_to = member_to_was
      end
    end

    def renewed?
      member_to && member_to.year >= RacingAssociation.current.effective_year
    end

    def renew!(license_type)
      ActiveSupport::Notifications.instrument "renew!.person.racing_on_rails", person_id: id, license_type: license_type

      self.member = true
      self.print_card = true
      self.license_type = license_type
      save!
    end
  end
end
