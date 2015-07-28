class MergeDuplicatesCreatedByEvents < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    DuplicatePerson.all_grouped_by_name(10_000).select do |name, people|
      original = people.sort_by(&:created_at).first
      people.each do |p|
        original = Person.find(original.id)
        if p != original &&
          p.created_by &&
          p.updated_at == p.created_at &&
          p.license.blank? &&
          (p.email.blank? || p.email == original.email) &&
          (p.created_by.is_a?(Event) || p.created_by.is_a?(SingleDayEvent) || p.created_by.is_a?(Event) ||
          p.created_by.is_a?(Series) || p.created_by.is_a?(Competitions::Competition) || p.created_by.is_a?(MultiDayEvent))

          say "Merge #{name}"
          original.merge(Person.find(p.id))
        end
      end
    end
  end
end
