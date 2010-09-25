class PersonObserver < ActiveRecord::Observer
  def after_destroy(person)
    Result.update_all [ "person_id=?, name=?, first_name=?, last_name=?", nil, nil, nil, nil ], [ "person_id=?", person.id ]
    true
  end

  def after_update(person)
    if person.first_name_changed? || person.last_name_changed?
      person.results.all.each do |result|
        if result[:name] != person.name(result.year)
          result.cache_attributes!
        end
      end
    end
    true
  end
end
