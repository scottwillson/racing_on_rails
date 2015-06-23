class MergePeopleWithSwappedFirstAndLastNames < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    Person.transaction do
      Person.where.not(first_name: nil).where.not(last_name: nil).where.not(license: nil).find_each do |person|
        if (person.first_name.size > 3 || person.last_name.size > 3) &&
          Person.where(first_name: person.last_name).where(last_name: person.first_name).exists?

          Person.where(first_name: person.last_name).where(last_name: person.first_name).each do |to_merge|
            if to_merge.license.blank? &&
               person.results.count > to_merge.results.count &&
               (!to_merge.respond_to?(:orders) || to_merge.orders.count == 0)

              say "Merge #{to_merge.name} => #{person.name} (created by #{to_merge.created_by.try(&:name)})"
              Person.find(person.id).merge(Person.find(to_merge))
            end
          end
        end
      end
    end
  end
end
