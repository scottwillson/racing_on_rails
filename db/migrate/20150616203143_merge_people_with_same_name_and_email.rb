class MergePeopleWithSameNameAndEmail < ActiveRecord::Migration
  def change
    DuplicatePerson.all_grouped_by_name(10_000).each do |name, people|
      original = people.sort_by(&:created_at).first
      people.each do |person|
        if person != original &&
          original.first_name.present? &&
          original.last_name.present? &&
          person.first_name.present? &&
          person.last_name.present? &&
          (person.email == original.email || original.email.blank? || person.email.blank?) &&
          (person.license.blank? || original.license.blank?) &&
          (original.team_name.blank? || person.team_name.blank? || original.team_name == person.team_name)

          say "Merge #{name}"
          Person.find(original.id).merge(person)
        end
      end
    end
  end
end
