class UsersPromotersRacersToPeople < ActiveRecord::Migration
  class Promoter < ActiveRecord::Base; end
  class Racer < ActiveRecord::Base; end
  class User < ActiveRecord::Base; end

  def self.up
    say "Clean up orphaned aliases"
    execute "delete from aliases where racer_id is not null and racer_id not in (select id from racers)"
    execute "delete from aliases where team_id is not null and team_id not in (select id from teams)"
    execute "delete from race_numbers where racer_id is not null and racer_id not in (select id from racers)"
    execute "update results set racer_id = null where racer_id is not null and racer_id not in (select id from racers)"
    
    say "Drop constraints"
    execute "alter table events drop foreign key events_promoters_id_fk"
    execute "alter table roles_users drop foreign key roles_users_user_id_fk"
    execute "alter table aliases drop foreign key aliases_racer_id_fk" rescue nil
    execute "alter table duplicates_racers drop foreign key duplicates_racers_racers_id_fk"
    execute "alter table race_numbers drop foreign key race_numbers_racer_id_fk" rescue nil
    execute "alter table results drop foreign key results_racer_id_fk" rescue nil
  
    say "Rename tables"
    rename_table :roles_users, :people_roles
    change_table :people_roles do |t|
      t.integer :person_id, :null => false, :default => nil
    end
    
    change_table :aliases do |t|
      t.rename :racer_id, :person_id
    end
    
    rename_table :duplicates_racers, :duplicates_people
    change_table :duplicates_people do |t|
      t.rename :racer_id, :person_id
    end
    
    change_table :race_numbers do |t|
      t.rename :racer_id, :person_id
    end
    
    change_table :pages do |t|
      t.rename :author_id, :user_id
      t.integer :author_id, :default => nil, :null => true
    end
    
    change_table :page_versions do |t|
      t.rename :author_id, :user_id
      t.integer :author_id, :default => nil, :null => true
    end
    
    change_table :results do |t|
      t.rename :racer_id, :person_id
    end
    
    rename_table :racers, :people
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
      t.string :login, :string, :null => true, :default => nil, :limit => 100
      t.rename :created_by_id, :created_by_user_id
      t.integer :created_by_id, :default => nil, :null => true
    end
    
    change_table :events do |t|
      t.rename :promoter_id, :old_promoter_id
      t.integer :promoter_id, :default => nil, :null => true
      t.string :phone, :default => nil
      t.string :email, :default => nil
    end

    change_table :teams do |t|
      t.rename :created_by_id, :created_by_user_id
      t.integer :created_by_id, :default => nil, :null => true
    end

    say "Add new constraint"
    add_index :people, :login, :unique => true
    add_index :people, :crypted_password
    add_index :people, :persistence_token
    add_index :people, :perishable_token
    add_index :people, :single_access_token
    execute "alter table events add constraint events_promoter_id foreign key (promoter_id) references people (id) on delete set null"
    execute "alter table aliases add constraint aliases_person_id foreign key (person_id) references people (id) on delete cascade"
    execute "alter table duplicates_people add constraint duplicates_people_person_id foreign key (person_id) references people (id) on delete cascade"
    execute "alter table race_numbers add constraint race_numbers_person_id foreign key (person_id) references people (id) on delete cascade"
    execute "alter table results add constraint results_person_id foreign key (person_id) references people (id)"

    say "Migrate Users"
    User.find.all().each do |user|
      person = Person.find_by_name(user.name)
      if person
        person.login = user.email
        person.email = user.email
        person.password = user.password
        person.password_confirmation = user.password
        person.save!
      else
        person = Person.create!(
          :login => user.email,
          :email => user.email,
          :password => user.password,
          :password_confirmation => user.password
        )
      end
      say "User #{user.id} #{user.name} Person #{person}"
      execute "update pages set author_id=#{person.id} where user_id=#{user.id}"
      execute "update page_versions set author_id=#{person.id} where user_id=#{user.id}"
      execute "update people_roles set person_id=#{person.id} where user_id=#{user.id}"
      execute "update people set created_by_id=#{person.id} where created_by_user_id=#{user.id} and created_by_type='User'"
      execute "update teams set created_by_id=#{person.id} where created_by_user_id=#{user.id} and created_by_type='User'"
    end

    execute "update people set crypted_password = '', persistence_token = '' where last_name = 'System'"
    
    # Nulls not allowed, so couldn't be enabled until now
    execute "alter table people_roles add constraint people_roles_person_id foreign key (person_id) references people (id) on delete cascade"
    execute "alter table pages add constraint pages_author_id foreign key (author_id) references people (id) on delete restrict"

    say "Migrate promoters"
    Promoter.find.all().each do |promoter|
      person = nil
      person = Person.find_by_name(promoter.name) unless promoter.name.blank?
      if person
        if person.email.present? && (person.email != promoter.email)
          execute "update events set email='#{promoter.email}' where old_promoter_id=#{promoter.id}"
        end

        if promoter.phone.present? && ![person.home_phone, person.work_phone, person.cell_fax].include?(promoter.phone)
          execute "update events set phone='#{promoter.phone}' where old_promoter_id=#{promoter.id}"
        end

        if person.email.blank?
          person.email = promoter.email          
        end

        unless [person.home_phone, person.work_phone, person.cell_fax].include?(promoter.phone)
          if person.home_phone.blank?
            person.home_phone = promoter.phone
          elsif person.work_phone.blank?
            person.work_phone = promoter.phone
          end
        end
        person.save!
      else
        person = Person.create!(
          :name => promoter.name,
          :email => promoter.email,
          :home_phone => promoter.phone
        )
      end
      execute "update events set promoter_id=#{person.id} where old_promoter_id=#{promoter.id}"
    end
    
    say "Add indexes"
    add_index :events, :promoter_id
    add_index :people_roles, :person_id
    add_index :people, :created_by_id
    add_index :teams, :created_by_id

    say "Drop tables and columns"
    change_table :pages do |t|
      t.remove :user_id
    end
    change_column :pages, :author_id, :integer, :default => nil, :null => false
    change_table :page_versions do |t|
      t.remove :user_id
    end
    change_column :page_versions, :author_id, :integer, :default => nil, :null => false
    change_table :people_roles do |t|
      t.remove :user_id
    end
    change_table :events do |t|
      t.remove :old_promoter_id
    end
    change_table :people do |t|
      t.remove :created_by_user_id
    end
    change_table :teams do |t|
      t.remove :created_by_user_id
    end
    drop_table :promoters
    drop_table :users
  end
end
