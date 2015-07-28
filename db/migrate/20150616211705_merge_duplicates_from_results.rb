class MergeDuplicatesFromResults < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    DuplicatePerson.all_grouped_by_name(10_000).each do |name, people|
      person_with_results = people.detect { |p| p.results.count > 1 && p.license.present? }

      if person_with_results
        people.each do |p|
          person_with_results = Person.find(person_with_results.id)
          p != person_with_results &&
          p.results.count <= 1 &&
          p.license.blank? &&
          (p.email.blank? || person_with_results.email == p.email)

          say "Merge #{name}"
          person_with_results.merge(Person.find(p.id))
        end
      end
    end
  end
end
