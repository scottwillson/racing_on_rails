class AddPageCreatedUpdatedBy < ActiveRecord::Migration
  def self.up
    rename_column :race_numbers, :updated_by, :old_updated_by
    RaceNumber.all.each do |race_number|
      if race_number.old_updated_by.blank?
        # Nothing to do
      elsif race_number.old_updated_by["xls"]
        file = ImportFile.find_or_create_by_name(race_number.old_updated_by)
        race_number.versions.create!(:user => file, :modifications => {})
      elsif (person = Person.find_by_name(race_number.old_updated_by)).present?
        race_number.versions.create!(:user => person, :modifications => {})
      elsif (event = Event.where("name = ? and YEAR(date) = ?", race_number.old_updated_by, race_number.year).first).present?
        race_number.versions.create!(:user => event)
      end
    end

    Person.all.each do |person|
      if person.last_updated_by.blank? || person.versions.present?
        # Nothing to do
      elsif person.last_updated_by["xls"]
        file = ImportFile.find_or_create_by_name(person.last_updated_by)
        person.versions.create!(:user => file, :modifications => {})
      elsif (updated_by_person = Person.find_by_name(person.last_updated_by)).present?
        person.versions.create!(:user => updated_by_person, :modifications => {})
      end
    end

    rename_column :people, :created_by_id, :old_created_by_id
    rename_column :people, :created_by_type, :old_created_by_type
    Person.where("old_created_by_id is not null").each do |person|
      person.versions.create!(:user => person.old_created_by_id, :modifications => {})
    end

    Team.where("created_by_id is not null").each do |team|
      if Person.exists?(team.created_by_id)
        team.versions.create!(:user => Person.find(team.created_by_id), :modifications => {})
      end
    end

    VestalVersions::Version.all.each do |version|
      if version.user_name.present?
        person = Person.find_by_name(version.user_name)
        if person
          version.user = person
        end
        version.user_name = nil
        begin
          version.save!        
        rescue Exception => e
          # Skip very small number of record with bad YAML
          puts "#{e}. Destroying bad version #{version.id}"
          version.destroy
        end
      end
    end

    remove_column :pages, :created_by_id

    remove_column :people, :last_updated_by
    remove_column :people, :old_created_by_type
    remove_column :people, :old_created_by_id

    remove_column :race_numbers, :old_updated_by

    remove_column :teams, :created_by_type
    remove_column :teams, :created_by_id
  end
end