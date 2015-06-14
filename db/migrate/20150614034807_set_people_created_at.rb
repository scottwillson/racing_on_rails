class SetPeopleCreatedAt < ActiveRecord::Migration
  def change
    Person.where(created_at: nil).each do |person|
      putc "."
      if person.updated_at
        person.created_at = person.updated_at
      else
        person.created_at = Time.zone.local(2006)
      end
      person.save!
    end

    puts
  end
end
