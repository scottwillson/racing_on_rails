class FixPeopleWithOnlyAFirstName < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    # Everyone outside of duplicates *should not* be Split
    # e.g., Guy with red helmet, Team Oregon
    DuplicatePerson.all(10_000).each do |person|
      if person.name != "No Name" && person.first_name.present? && person.last_name.blank? && person.first_name[" "]
        say "Split first name '#{person.name}'"
        person.name = person.name
        person.save!
      end
    end
  end
end
