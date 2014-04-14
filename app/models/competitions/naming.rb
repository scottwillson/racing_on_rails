module Competitions
  module Naming
    def name
      self[:name] ||= "#{self.date.year} #{friendly_name}"
    end

    def default_name
      name
    end

    def friendly_name
      "Competition"
    end
  end
end
