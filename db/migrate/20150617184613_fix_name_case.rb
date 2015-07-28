class FixNameCase < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    Person.all.each do |person|
      name = person.name
      if name.present? && person.last_name.present? && (name == name.downcase || name == name.upcase)
        say "#{name} => #{name.titlecase}"
        person.name = name.titlecase
        person.save!
      end
    end
  end
end
