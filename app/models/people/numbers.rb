module People
  module Numbers
    extend ActiveSupport::Concern

    included do
      has_many :race_numbers, -> { includes(:discipline, :number_issuer) }

      accepts_nested_attributes_for :race_numbers,
        reject_if: proc { |attributes| !attributes.has_key?(:value) || attributes[:value].blank? }

      def self.find_all_by_number(number)
        RaceNumber.
          includes(:person).
          where(year: [ RacingAssociation.current.year, RacingAssociation.current.next_year ]).
          where(value: number).
          map(&:person)
      end
    end

    def number(discipline_param, reload = false, year = nil)
      return nil if discipline_param.nil?

      year ||= RacingAssociation.current.year
      if discipline_param.is_a?(Discipline)
        discipline_param = discipline_param.to_param
      end
      number = race_numbers(reload).detect do |race_number|
        race_number.year == year &&
        race_number.discipline_id == RaceNumber.discipline_id(discipline_param) &&
        race_number.number_issuer.name == RacingAssociation.current.short_name
      end
      number.try :value
    end

    # Look for RaceNumber +year+ in +attributes+. Not sure if there's a simple and better way to do that.
    # Need to set +updated_by+ before setting numbers to ensure updated_by is passed to number. Setting all via a
    # parameter hash may add number before updated_by is set.
    def add_number(value, discipline, association = nil, _year = year)
      association = NumberIssuer.find_by_name(RacingAssociation.current.short_name) if association.nil?
      _year ||= RacingAssociation.current.year

      if discipline.nil? || !discipline.numbers?
        discipline = Discipline[:road]
      end

      if value.blank?
        unless new_record?
          # Delete ALL numbers for RacingAssociation.current and this discipline?
          # FIXME Delete number individually in UI
          RaceNumber.destroy_all(
            ['person_id=? and discipline_id=? and year=? and number_issuer_id=?',
            self.id, discipline.id, _year, association.id])
        end
      else
        if new_record?
          existing_number = race_numbers.any? do |number|
            number.value == value && number.discipline == discipline && number.association == association && number.year == _year
          end
          race_numbers.build(
            value: value, discipline: discipline, year: _year, number_issuer: association,
            updated_by: updated_by
          ) unless existing_number
        else
          RaceNumber.where(
            value: value, person_id: id, discipline_id: discipline.id, year: _year, number_issuer_id: association.id
          ).first || race_numbers.create(
            value: value, discipline: discipline, year: _year, number_issuer: association, updated_by: updated_by
          )
        end
      end
    end

    def bmx_number(reload = false, year = nil)
      number(Discipline[:bmx], reload, year)
    end

    def ccx_number(reload = false, year = nil)
      number(Discipline[:cyclocross], reload, year)
    end

    def dh_number(reload = false, year = nil)
      number(Discipline[:downhill], reload, year)
    end

    def road_number(reload = false, year = nil)
      number(Discipline[:road], reload, year)
    end

    def singlespeed_number(reload = false, year = nil)
      number(Discipline[:singlespeed], reload, year)
    end

    def track_number(reload = false, year = nil)
      number(Discipline[:track], reload, year)
    end

    def xc_number(reload = false, year = nil)
      number(Discipline[:mountain_bike], reload, year)
    end

    def bmx_number=(value)
      add_number(value, Discipline[:bmx])
    end

    def ccx_number=(value)
      add_number(value, Discipline[:cyclocross])
    end

    def dh_number=(value)
      add_number(value, Discipline[:downhill])
    end

    def road_number=(value)
      add_number(value, Discipline[:road])
    end

    def singlespeed_number=(value)
      add_number(value, Discipline[:singlespeed])
    end

    def track_number=(value)
      add_number(value, Discipline[:track])
    end

    def xc_number=(value)
      add_number(value, Discipline[:mountain_bike])
    end
  end
end
