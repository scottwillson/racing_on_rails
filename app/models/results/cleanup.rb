# frozen_string_literal: true

module Results
  module Cleanup
    extend ActiveSupport::Concern

    # Fix common formatting mistakes and inconsistencies
    def cleanup
      cleanup_age
      cleanup_city
      cleanup_number
      cleanup_license
      cleanup_place
      self.first_name = cleanup_name(first_name)
      self.last_name = cleanup_name(last_name)
      self.team_name = cleanup_name(team_name)
    end

    def cleanup_age
      self.age = nil if age && age.to_i == 0
    end

    def cleanup_city
      self.city = nil if city == "(blank)"
    end

    # Drops the 'st' from 1st, among other things
    def cleanup_place
      if place
        normalized_place = place.to_s.dup
        normalized_place.upcase!
        normalized_place.gsub!("ST", "")
        normalized_place.gsub!("ND", "")
        normalized_place.gsub!("RD", "")
        normalized_place.gsub!("TH", "")
        normalized_place.delete!(")")
        normalized_place = normalized_place.to_i.to_s if normalized_place[/^\d+\.0$/]
        normalized_place.strip!
        normalized_place.delete!(".")
        self.place = normalized_place
      else
        self.place = ""
      end
    end

    def cleanup_number
      return if number.nil?

      _number = number.to_s.strip.truncate(8)

      _number = number.to_i.to_s if _number[/^\d+\.0$/]

      self.number = _number
    end

    def cleanup_license
      self.license = license.to_s
      # USAC license numbers are being imported with a one decimal zero, e.g., 12345.0
      self.license = license.to_i.to_s if license[/^\d+\.0$/]
    end

    # Mostly removes unfortunate punctuation typos
    def cleanup_name(name)
      return name if name.nil?

      name = name.to_s.strip
      return "" if name == "0.0"
      return "" if name == "0"
      return "" if name == "."
      return "" if name.include?("N/A")

      name = name.tr(";", "'")
      name.gsub(%r{ */ *}, "/")
    end
  end
end
