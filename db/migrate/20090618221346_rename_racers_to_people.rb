class RenameRacersToPeople < ActiveRecord::Migration
  def self.up
    execute "alter table aliases drop foreign key aliases_racer_id_fk"
    execute "alter table duplicates_racers drop foreign key duplicates_racers_racers_id_fk"
    execute "alter table race_numbers drop foreign key race_numbers_racer_id_fk"
    execute "alter table results drop foreign key results_racer_id_fk"

    change_table :aliases do |t|
      t.rename(:racer_id, :person_id)
    end
    rename_table :duplicates_racers, :duplicates_people
    change_table :duplicates_people do |t|
      t.rename :racer_id, :person_id
    end
    rename_table :racers, :people
    change_table :race_numbers do |t|
      t.rename :racer_id, :person_id
    end
    change_table :results do |t|
      t.rename :racer_id, :person_id
    end
    
    execute "alter table aliases add foreign key (person_id) references people (id) on delete cascade"
    execute "alter table duplicates_people add foreign key (person_id) references people (id) on delete cascade"
    execute "alter table race_numbers add foreign key (person_id) references people (id) on delete cascade"
    execute "alter table results add foreign key (person_id) references people (id)"
  end

  def self.down
    execute "alter table aliases drop foreign key aliases_person_id_fk"
    execute "alter table duplicates_persons drop foreign key duplicates_persons_persons_id_fk"
    execute "alter table race_numbers drop foreign key race_numbers_person_id_fk"
    execute "alter table results drop foreign key results_person_id_fk"

    change_table :duplicates_people do |t|
    end
    change_table :aliases do |t|
      t.rename(:person_id, :racer_id)
    end
    rename_table :duplicates_people, :duplicates_racers
    change_table :duplicates_racers do |t|
      t.rename :person_id, :racer_id
    end
    rename_table :people, :racers
    change_table :race_numbers do |t|
      t.rename :person_id, :racer_id
    end
    change_table :results do |t|
      t.rename :person_id, :racer_id
    end

    execute "alter table aliases add foreign key (racer_id) references people (id) on delete cascade"
    execute "alter table duplicates_racers add foreign key (racer_id) references people (id) on delete cascade"
    execute "alter table race_numbers add foreign key (racer_id) references people (id) on delete cascade"
    execute "alter table results add foreign key (racer_id) references people (id)"
  end
end
