class CreatePeoplePeople < ActiveRecord::Migration
  def self.up
    create_table :people_people, :force => true, :id => false do |t|
      t.integer :person_id, :null => false, :default => nil
      t.integer :editor_id, :null => false, :default => nil
    end
    
    add_index :people_people, :editor_id
    add_index :people_people, :person_id
    add_index :people_people, [ :editor_id, :person_id ], :unique => true
    
    execute "alter table people_people add constraint foreign key (`editor_id`) references `people` (`id`) on delete cascade"
    execute "alter table people_people add constraint foreign key (`person_id`) references `people` (`id`) on delete cascade"
    
    Person.find(:all, :conditions => "last_name is not null and last_name != '' and email is not null and email != ''").each do |person|
      Person.find(:all, :conditions => ["last_name is not null and last_name != '' and email = ? and id != ?", person.email, person.id] ).each do |other_person|
        say "#{person.name} and #{other_person.name} share #{person.email}"
        unless person.editors.include?(other_person)
          person.editors << other_person
        end
        unless other_person.editors.include?(person)
          other_person.editors << person
        end
      end
    end
  end

  def self.down
    drop_table :people_people
  end
end
