class MergePeopleDuplicatedByMtbRaces < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    mtb_races = [ "Sister's Stampede XC", "ROTJ (Return on the Jedi)", "Spring Thaw", "Echo Red to Red XC",
      "Mudslinger", "Medio", "High Cascades 100" ]

    DuplicatePerson.all_grouped_by_name(10_000).each do |name, people|
      original = people.sort_by(&:created_at).first
      people.each do |p|
        original = Person.find(original.id)
        if p != original &&
          p.created_by && p.created_by.name.in?(mtb_races) &&
          (p.email.blank? || p.email == original.email) &&
          (p.license.blank? || original.license.blank?)

          say "Merge #{name} created by #{p.created_by.name}"
          original.merge(Person.find(p.id))
        end
      end
    end
  end
end
