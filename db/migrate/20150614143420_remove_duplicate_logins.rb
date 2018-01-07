# frozen_string_literal: true

class RemoveDuplicateLogins < ActiveRecord::Migration
  def change
    Person.current = RacingAssociation.current.person

    logins = Person.where("login is not null").where("login != ''").group(:login).having("count(login) > 1").count.keys
    Person.where(login: logins).group_by { |l| l.login.downcase.strip }.each do |_login, people|
      person = people.select(&:current_login_at).sort_by(&:current_login_at).last
      people.each do |p|
        next unless p != person
        person.login = nil
        person.password = nil
        person.password_confirmation = nil
        person.save!
        putc "."
      end
    end
    puts
  end
end
