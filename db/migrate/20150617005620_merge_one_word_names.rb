class MergeOneWordNames < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    Person.transaction do
      DuplicatePerson.all_grouped_by_name(10_000).each do |name, people|
        if !name[" "]
          say "Merge #{name}"
          original = people.first
          people.each do |p|
            original = Person.find(original.id)
            if p != original && p.license.blank?
              original.merge(Person.find(p.id))
            end
          end
        end
      end
    end
  end
end
