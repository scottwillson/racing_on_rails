# frozen_string_literal: true

module Categories
  module Ages
    extend ActiveSupport::Concern

    JUNIORS =  9..18
    SENIOR  = 19..29
    MASTERS = 30..::Categories::MAXIMUM.freeze

    included do
      before_save :set_ages_from_name
    end

    def age_group?
      ages_begin && ages_end && (ages_begin != 0 || ages_end != ::Categories::MAXIMUM)
    end

    def and_over?
      ages_end && ages_end == ::Categories::MAXIMUM
    end

    def junior?
      age_group? && ages_end <= JUNIORS.end
    end

    def masters?
      age_group? && ages_begin >= MASTERS.begin
    end

    def senior?
      age_group? && ages.in?(SENIOR)
    end

    # Return Range
    def ages
      ages_begin..ages_end
    end

    # Accepts an age Range like 10..18, or a String like 10-18
    def ages=(value)
      case value
      when Range
        self.ages_begin = value.begin
        self.ages_end = value.end
      else
        age_split = value.strip.split('-')
        self.ages_begin = age_split[0].to_i unless age_split[0].nil?
        self.ages_end = age_split[1].to_i unless age_split[1].nil?
      end
      self.ages
    end

    def set_ages_from_name
      if ages_begin.nil? || ages_begin == 0
        self.ages = ages_from_name(name)
      end
      ages
    end

    def set_ages_from_name!
      self.ages = ages_from_name(name)
    end

    def ages_from_name(name)
      if name[/\d{3}-\d{3}/]
        age_range_match = /(\d{3})-(\d{3})/.match(name)
        ages_begin = age_range_match[1].to_i / team_size(name)
        ages_end = ((age_range_match[2].to_i + 1) / team_size(name)) - 1
        ages_begin..ages_end
      elsif name[/\d{3}\+/]
        ages_begin = name[/(\d{3})\+/]
        (ages_begin.to_i / team_size(name))..::Categories::MAXIMUM
      elsif name["+"]
        if name["Junior"]
          (name[/(9|1\d)\+/].to_i)..JUNIORS.end
        else
          (name[/(\d{2})\+/].to_i)..::Categories::MAXIMUM
        end
      elsif /(9|\d{2})-(9|\d{2})/.match(name)
        age_range_match = /(9|\d{2})-(9|\d{2})/.match(name)
        age_range_match[1].to_i..age_range_match[2].to_i
      elsif name["Junior"]
        if /[^\d](9|1\d)/.match(name)
          age = /[^\d](9|\d{2})/.match(name)[1].to_i
          age..age
        else
          JUNIORS
        end
      elsif name["Master"]
        MASTERS
      elsif name[/U\d\d/]
        0..(/U(\d\d)/.match(name)[1].to_i - 1)
      else
        ALL
      end
    end

    def team_size(name)
      if name["Two-Person"]
        2
      else
        4
      end
    end
  end
end
