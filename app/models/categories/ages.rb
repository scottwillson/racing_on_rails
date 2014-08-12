module Categories
  module Ages
    extend ActiveSupport::Concern

    included do
      before_save :set_age_from_name
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
    end

    def set_age_from_name
      if ages_begin.nil? || ages_begin == 0
        if name["+"]
          self.ages = (name[/(\d\d)\+/].to_i)..999
        else
          age_range_match = /(\d\d)-(\d\d)/.match(name)
          if age_range_match
            self.ages = age_range_match[1]..age_range_match[2]
          end
        end
      end
    end
  end
end
