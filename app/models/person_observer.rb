# frozen_string_literal: true

class PersonObserver < ActiveRecord::Observer
  def after_destroy(person)
    Result.where(person_id: person.id).update_all(
      person_id: nil,
      name: nil,
      first_name: nil,
      last_name: nil
    )
    true
  end

  def around_update(person)
    if person.first_name_changed? || person.last_name_changed?
      person.results.each do |result|
        result.cache_attributes!(:non_event) if result[:name] != person.name(result.year)
      end
    end

    yield
  end
end
