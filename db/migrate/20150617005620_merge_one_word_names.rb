# frozen_string_literal: true

class MergeOneWordNames < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    Person.transaction do
      DuplicatePerson.all_grouped_by_name(10_000).each do |name, people|
        next if name[" "]
        say "Merge #{name}"
        original = people.first
        people.each do |p|
          if Person.exists?(original.id) && Person.exists?(p.id)
            original = Person.find(original.id)
            original.merge(Person.find(p.id)) if p != original && p.license.blank?
          end
        end
      end
    end
  end
end
