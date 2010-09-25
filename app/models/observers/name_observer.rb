class NameObserver < ActiveRecord::Observer
  def after_create(name)
    case name.nameable
    when Person
      name.nameable.results.all.each do |result|
        if result[:name] != name.nameable.name(result.year)
          result.event.disable_notification!
          result.cache_attributes
          result.save!
          result.event.enable_notification!
        end
      end
    when Team
      name.nameable.results.all.each do |result|
        if result[:team_name] != name.nameable.name(result.year)
          result.logger.debug "NameObserver#after_create set result name #{result[:team_name]} to #{name.nameable.name(result.year)}"
          result.event.disable_notification!
          result.cache_attributes
          result.save!
          result.logger.debug "NameObserver#after_create #{result[:team_name]}"
          result.event.enable_notification!
        end
      end
    end
    true
  end
end
