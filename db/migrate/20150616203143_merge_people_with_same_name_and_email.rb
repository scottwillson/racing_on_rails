class MergePeopleWithSameNameAndEmail < ActiveRecord::Migration

  def change
    create_table :event_teams, force: true do |t|
      t.references :event, null: false
      t.references :team, null: false

      t.timestamps

      t.index :event_id
      t.index :team_id
      t.index [ :event_id, :team_id ], unique: true
    end

    create_table :event_team_memberships, force: true do |t|
      t.references :event_team, null: false
      t.references :person, null: false

      t.timestamps

      t.index :event_team_id
      t.index :person_id
      t.index [ :event_team_id, :person_id ], unique: true
    end

    Person.reset_column_information

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
