class MergePeopleWithSameNameAndEmail < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    Person.transaction do
      DuplicatePerson.all_grouped_by_name(10_000).each do |name, people|
        original = people.sort_by(&:created_at).first
        people.each do |person|
          # Order cleanup can delete people
          if Person.exists?(original.id) && Person.exists?(person.id)

            original = Person.find(original.id)
            if person != original &&
              original.first_name.present? &&
              original.last_name.present? &&
              person.first_name.present? &&
              person.last_name.present? &&
              (person.email == original.email || original.email.blank? || person.email.blank?) &&
              (person.license.blank? || original.license.blank?) &&
              (original.team_name.blank? || person.team_name.blank? || original.team_name == person.team_name) &&
              person.date_of_birth.blank?

              say "Merge #{name}"
              person = Person.find(person.id)
              original.merge(person)
            end
          end
        end
      end
    end
  end
end
