class NameObserver < ActiveRecord::Observer
  def after_create(name)
    case name.nameable
    when Person
      name.nameable.results.each do |result|
        if result[:name] != name.nameable.name(result.year)
          result.cache_attributes! :non_event
        end
      end
    when Team
      name.nameable.results.each do |result|
        if result[:team_name] != name.nameable.name(result.year)
          result.cache_attributes! :non_event
        end
      end
    end
    true
  end
end
