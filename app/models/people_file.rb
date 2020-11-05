# frozen_string_literal: true

# Excel or text file of People. Assumes that the first row is a header row.
# Updates membership to current year. If there are no more events in the current year, updates membership to next year.
# See http://racingonrails.rocketsurgeryllc.com/sample_import_files/ for format details and examples.
class PeopleFile
  attr_reader :created
  attr_reader :duplicates
  attr_reader :path
  attr_reader :table
  attr_reader :updated

  def initialize(path)
    @created = 0
    @duplicates = []
    @path = path
    @updated = 0

    @table = Tabular::Table.new
    table.column_mapper = People::ColumnMapper.new

    table.columns.each do |column|
      column.type = :boolean if column.key == :ccx_only || column.key == :fabric_road_numbers
    end

    table.read path
    table.strip!
  end

  # +year+ for RaceNumbers
  # New memberships start on today, but really should start on January 1st of next year, if +year+ is next year
  def import(update_membership, year = nil)
    ActiveSupport::Notifications.instrument(
      "import.people_file.racing_on_rails", update_membership: update_membership, import_file: import_file, rows: table.rows.size
    ) do

      @update_membership = update_membership

      @has_print_column = table.columns.any? do |column|
        column.key == :print_card
      end

      year = year.to_i if year
      assign_member_from_imported_people year

      boolean_attributes = Person.columns.select { |c| c.type == :boolean }.map(&:name)

      Person.transaction do
        table.rows.map(&:to_hash).each do |row|
          row[:updater] = import_file
          logger.debug(row.inspect) if logger.debug?
          next if blank_name?(row)

          row.each do |key, value|
            row[key] = false if key.to_s.in?(boolean_attributes) && value.blank?
          end

          combine_categories row
          delete_blank_categories row
          delete_bad_date_of_birth row

          people = find_people(row)

          row[:member_to] = @member_to_for_imported_people if @update_membership

          if people.empty?
            create_person row, year
          elsif people.size == 1
            update_person row, people.first, year
          else
            create_duplicate row, year, people
          end
        end
      end
    end
    [@created, @updated]
  end

  def find_people(row)
    people = []

    people = Person.where(license: row[:license]) if row[:license].present? && row[:license].to_i > 0

    people = Person.find_all_by_name_or_alias(first_name: row[:first_name], last_name: row[:last_name]) if people.empty?

    ActiveSupport::Notifications.instrument(
      "find.people_file.racing_on_rails",
      people_count: people.size,
      person_first_name: row[:first_name],
      person_last_name: row[:last_name],
      license: row[:license]
    )

    people
  end

  def create_person(row, year)
    ActiveSupport::Notifications.instrument "create.people_file.racing_on_rails", person_first_name: row[:first_name], person_last_name: row[:last_name]
    delete_unwanted_member_from row, nil
    add_print_card_and_label row
    person = Person.new(updater: import_file)
    person.year = year if year
    person.update! row
    @created += 1
  end

  def update_person(row, person, year)
    ActiveSupport::Notifications.instrument "update.people_file.racing_on_rails", person_id: person.id, person_name: person.name

    delete_unwanted_member_from row, person
    row[:notes] = if person.notes.present? && row[:notes].present? && person.notes != row[:notes]
                    [person.notes, row[:notes]].join($INPUT_RECORD_SEPARATOR)
                  else
                    person.notes
                  end
    add_print_card_and_label row, person

    person.year = year if year
    person.updater = import_file
    person.update! row

    @updated += 1
  end

  def create_duplicate(row, year, people)
    person = Person.new(row)

    ActiveSupport::Notifications.instrument "duplicate.people_file.racing_on_rails", person_name: person.name, people_count: people.size, people_ids: people.map(&:id)

    person.year = year if year
    delete_unwanted_member_from row, person
    row[:notes] = "#{people.last.notes}#{$INPUT_RECORD_SEPARATOR}#{row[:notes]}" if person.notes.present?
    add_print_card_and_label row, person

    row.delete :persistence_token
    row.delete :single_access_token
    row.delete :perishable_token

    duplicates << Duplicate.create!(new_attributes: Person.new(row).serializable_hash, people: people)
  end

  private

  def assign_member_from_imported_people(year)
    if @update_membership
      @member_from_imported_people = if year && year > Time.zone.today.year
                                       Time.zone.local(year).beginning_of_year.to_date
                                     else
                                       Time.zone.today.to_date
                                     end
      @member_to_for_imported_people = Time.zone.local(year || Time.zone.today.year).end_of_year.to_date
    end
  end

  def blank_name?(row)
    row[:first_name].blank? && row[:first_name].blank? && row[:name].blank?
  end

  def combine_categories(row)
    Person::CATEGORY_FIELDS.each do |field|
      row[field] = row[field].to_s.tr("\n", " ") if row[field].present?
    end
  end

  def delete_bad_date_of_birth(row)
    row.delete(:date_of_birth) if row[:date_of_birth] == "xx"
  end

  # Don't want to overwrite existing categories
  def delete_blank_categories(row)
    Person::CATEGORY_FIELDS.each do |field|
      row.delete(field) if row[field].blank?
    end
  end

  def delete_unwanted_member_from(row, person)
    # Just in case
    row.delete(:login)

    if row[:member_from].blank?
      row.delete(:member_from)
      return
    end

    unless person.nil?
      if person.member_from
        row[:member_from] = person.member_from if row[:member_from] > person.member_from.to_date
      end
    end
  end

  def add_print_card_and_label(row, person = nil)
    if @update_membership && !@has_print_column
      row[:print_card] = true if person.nil? || (!person.member? || person.member_to.to_date < @member_to_for_imported_people.to_date)
    end
  end

  def import_file
    @import_file ||= if @path
                       ImportFile.create!(name: "#{@path} #{Person.current.try(:name_or_login)}")
                     else
                       ImportFile.create!(name: "#{Person.current.try(:name_or_login)} file")
                     end
    @import_file
  end

  def logger
    Rails.logger
  end
end
