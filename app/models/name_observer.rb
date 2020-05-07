# frozen_string_literal: true

class NameObserver < ActiveRecord::Observer
  def after_create(name)
    case name.nameable
    when Person
      name.nameable.results.each do |result|
        result.cache_attributes! :non_event if result[:name] != name.nameable.name(result.year)
      end
    when Team
      name.nameable.results.each do |result|
        result.cache_attributes! :non_event if result[:team_name] != name.nameable.name(result.year)
      end
    end
    true
  end
end
