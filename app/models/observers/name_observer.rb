class NameObserver < ActiveRecord::Observer
  def after_create(name)
    case name.nameable
    when Person
      name.nameable.results.all.each do |result|
        if result[:name] != name.nameable.name(result.year)
          result.cache_attributes!
        end
      end
    when Team
      name.nameable.results.all.each do |result|
        if result[:team_name] != name.nameable.name(result.year)
          result.cache_attributes!
        end
      end
    end
    true
  end
end
