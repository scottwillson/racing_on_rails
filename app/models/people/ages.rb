# frozen_string_literal: true

module People
  module Ages
    extend ActiveSupport::Concern

    def date_of_birth=(value)
      value = case value
              when String
                if value[%r{^\d\d/\d\d/\d\d$}]
                  value.gsub %r{(\d+)/(\d+)/(\d+)}, '19\3/\1/\2'
                else
                  value.gsub(/^00/, "19")
                       .gsub(%r{^(\d+/\d+/)(\d\d)$}, '\119\2')
                end
              when Array
                Date.new(value[0], value[1], value[2])
              when Hash
                Date.new(value[1], value[2], value[3])
              else
                value
              end

      if value && value.to_s.size < 5
        int_value = value.to_i
        value = "01/01/19#{value}" if int_value > 10 && int_value <= 99
        value = "01/01/20#{value}" if int_value > 0 && int_value <= 10
      end

      # Don't overwrite month and day if we're just passing in the same year
      if self[:date_of_birth] && value
        new_date = if value.is_a?(String)
                     Date.parse(value)
                   else
                     value
                   end
        return if new_date.year == self[:date_of_birth].year && new_date.month == 1 && new_date.day == 1
      end

      super value
    end

    def birthdate
      date_of_birth
    end

    def birthdate=(value)
      self.date_of_birth = value
    end

    # 30 years old or older
    def master?
      date_of_birth <= Date.new(RacingAssociation.current.masters_age.years.ago.year, 12, 31) if date_of_birth
    end

    # Under 18 years old
    def junior?
      date_of_birth >= Date.new(18.years.ago.year, 1, 1) if date_of_birth
    end

    # 21 years old or under (U21)
    def twenty_one_and_under?
      date_of_birth >= Date.new(21.years.ago.year, 1, 1) if date_of_birth
    end

    # Over 18 years old
    def senior?
      date_of_birth < Date.new(18.years.ago.year, 1, 1) if date_of_birth
    end

    def age_category
      if female?
        if junior?
          "girl"
        else
          "woman"
        end
      elsif master?
        "master"
      elsif junior?
        "boy"
      else
        "man"
      end
    end

    # Oldest age person will be at any point in year
    def racing_age(year = RacingAssociation.current.year)
      (year - date_of_birth.year).ceil if date_of_birth
    end

    def cyclocross_racing_age
      racing_age + 1 if date_of_birth
    end
  end
end
