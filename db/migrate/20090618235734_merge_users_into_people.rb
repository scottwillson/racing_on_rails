class MergeUsersIntoPeople < ActiveRecord::Migration
  class Racer < ActiveRecord::Base; end

  class User < ActiveRecord::Base
    acts_as_authentic do |config|
      config.validates_length_of_email_field_options :within => 6..72, :allow_nil => true, :allow_blank => true
      config.validates_format_of_email_field_options :with => Authlogic::Regex.email, 
                                                     :message => I18n.t('error_messages.email_invalid', :default => "should look like an email address."),
                                                     :allow_nil => true,
                                                     :allow_blank => true
      config.validates_length_of_password_field_options  :minimum => 4, :allow_nil => true, :allow_blank => true
      config.validates_length_of_password_confirmation_field_options  :minimum => 4, :allow_nil => true, :allow_blank => true
    end
  end

  def self.up
    change_table :people do |t|
      t.string    :crypted_password, :null => true
      t.string    :password_salt, :null => true
      t.string    :persistence_token, :null => false
      t.string    :single_access_token, :null => true
      t.string    :perishable_token, :null => true
      t.integer   :login_count,         :null => false, :default => 0
      t.integer   :failed_login_count,  :null => false, :default => 0
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip
    end
    
    add_index :people, :email, :unique => true

    User.find(:all) do |user|
      person = People.find_by_name(user.name)
      if person
        person.email = user.email
        person.home_phone = user.phone
        person.crypted_password = user.crypted_password
        person.password_salt = user.password_salt
        person.single_access_token = user.single_access_token
        person.persistence_token = user.persistence_token
      else
        Person.create!(
          :email => user.email,
          :home_phone => user.phone,
          :crypted_password => user.crypted_password,
          :password_salt => user.password_salt,
          :single_access_token => user.single_access_token,
          :persistence_token => user.single_access_token
        )
      end
    end
    
    rename_table :roles_users, :people_roles
    change_table :people_roles do |t|
      t.rename(:user_id, :person_id)
    end
    

    execute "alter table events drop foreign key events_promoters_id_fk"
    execute "alter table people_roles drop foreign key roles_users_user_id_fk"

    drop_table :users

    execute "alter table events add foreign key (promoter_id) references people (id) on delete set null"
    execute "alter table people_roles add foreign key (person_id) references people (id) on delete cascade"
  end
end
