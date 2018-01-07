# frozen_string_literal: true

class SetPeopleCreatedAt < ActiveRecord::Migration
  def change
    Person.where(created_at: nil).each do |person|
      putc "."
      person.created_at = if person.updated_at
                            person.updated_at
                          else
                            Time.zone.local(2006)
                          end
      person.save!
    end

    puts
  end
end
