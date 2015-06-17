class MergePeopleWithSameNameAndBirthdates < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    DuplicatePerson.all_grouped_by_name(10_000).select do |name, people|
      original = people.sort_by(&:created_at).first
      people.each do |person|
        original = Person.find(original.id)
        if person != original &&
          person.date_of_birth &&
          original.date_of_birth &&
          person.date_of_birth.year == original.date_of_birth.year &&
          person.date_of_birth.month == original.date_of_birth.month

          say "Merge #{name}"
          original.merge(Person.find(person.id))
        end
      end
    end
  end
end
