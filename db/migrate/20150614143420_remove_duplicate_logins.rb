class RemoveDuplicateLogins < ActiveRecord::Migration
  def change
    logins = Person.where("login is not null").where("login != ''").group(:login).having("count(login) > 1").count.keys
    Person.where(login: logins).group_by {|l| l.login.downcase.strip}.each do |login, people|
      person = people.select {|p| p.current_login_at}.sort_by(&:current_login_at).last
      people.each do |p|
        if p != person
          person.login = nil
          person.password = nil
          person.password_confirmation = nil
          person.updated_by = RacingAssociation.current
          person.save!
          putc "."
        end
      end
    end
    puts
  end
end
