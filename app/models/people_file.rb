require_dependency "grid/grid_file"

# Excel or text file of People. Assumes that the first row is a header row.
# Updates membership to current year. If there are no more events in the current year, updates membership to next year.
# See http://racingonrails.rocketsurgeryllc.com/sample_import_files/ for format details and examples.
class PeopleFile < Grid::GridFile
  # 'club' ...this is often team in USAC download. How handle? Use club for team if no team? and if both, ignore club?
  #  'NCCA club' ...can have this in addition to club and team. should team be many to many?

  COLUMN_MAP = {
    'team'                                   => 'team_name',
    'Cycling Team'                           => 'team_name',
    'club'                                   => 'club_name',
    'ncca club'                              => 'ncca_club_name',
    'fname'                                  => 'first_name',
    'lname'                                  => 'last_name',
    'f_name'                                 => 'first_name',
    'l_name'                                 => 'last_name',
    'FirstName'                              => 'first_name',
    'first name'                             => 'first_name',
    'LastName'                               => 'last_name',
    'last name'                              => 'last_name',
    'AAA Last Name'                          => 'last_name',
    'Birth date'                             => 'date_of_birth',
    'Birthdate'                              => 'date_of_birth',
    'year of birth'                          => 'date_of_birth',
    'dob'                                    => 'date_of_birth',
    'address'                                => 'street',
    'Address1_Contact address'               => 'street',
    'Address2_Contact address'               => 'street',
    'address1'                               => 'street',
    'City_Contact address'                   => 'city',
    'State_Contact address'                  => 'state',
    'Zip_Contact address'                    => 'zip',
    'Phone'                                  => 'home_phone',
    'DayPhone'                               => 'home_phone',
    'cell/fax'                               => 'cell_fax',
    'cell'                                   => 'cell_fax',
    'e-mail'                                 => 'email',
    'category'                               => 'road_category',
    'road cat'                               => 'road_category',
    'Cat.'                                   => 'road_category',
    'cat'                                    => 'road_category',
    'Road Category - '                       => 'road_category',
    'Road Age Group - '                      => 'road_category',
    'USCF Category'                          => 'road_category',
    'track cat'                              => 'track_category',
    'Track Category - '                      => 'track_category',
    'Track Age Group - '                     => 'track_category',
    'Cyclocross Category - '                 => 'ccx_category',
    'cross cat'                              => 'ccx_category',
    'ccx cat'                                => 'ccx_category',
    'Cyclocross Age Group -'                 => 'ccx_category',
    'Cross Country Mountain Bike Category -' => 'mtb_category',
    'mtn cat'                                => 'mtb_category',
    'Cross Country Mountain Age Group -'     => 'mtb_category',
    'XC'                                     => 'mtb_category',
    'Downhill Mountain Bike Category - '     => 'dh_category',
    'dh cat'                                 => 'dh_category',
    'dh'                                     => 'dh_category',
    'Downhill Mountain Bike Age Group -'     => 'dh_category',
    'number'                                 => 'road_number',
    '2009 road'                              => 'road_number',
    'WSBA #'                                 => 'road_number',
    '2009 xc'                                => 'xc_number',
    'mtb #'                                  => 'xc_number',
    '09 dh'                                  => 'dh_number',
    'singlespeed'                            => 'singlespeed_number',
    '2009 ss'                                => 'singlespeed_number',
    'ss'                                     => 'singlespeed_number',
    'ss #'                                   => 'singlespeed_number',
    'Membership No'                          => 'license',
    'license#'                               => 'license',
    'date joined'                            => 'member_from',
    'exp date'                               => 'member_usac_to',
    'expiration date'                        => 'member_usac_to',
    'card'                                   => 'print_card',
    'sex'                                    => 'gender',
    'What is your occupation? (optional)'    => 'occupation',
    'Suspension'                             => 'status',   #e.g. "SUSPENDED - Contact USA Cycling"
    'Interests'                              => 'notes',
    'Receipt Code'                           => 'notes',
    'Confirmation Code'                      => 'notes',
    'Transaction Payment Total'              => 'notes',
    'Registration Completion Date/Time'      => 'notes',
    'Donation'                               => 'notes',
    'Singlespeed'                            => 'notes',
    'Tandem'                                 => 'notes',
    'Please select a category:'              => Grid::Column.new(name: 'notes', description: 'Disciplines'),
    '2009 notes'                             => 'notes',
    'Would you like to make an additional donation to support OBRA? '                 => Grid::Column.new(name: 'notes', description: 'Donation'),
    'Please indicate if you are interested in racing cross country or downhill. '     => Grid::Column.new(name: 'notes', description: 'Downhill/Cross Country'),
    'Please indicate if you are interested in racing single speed.'                   => Grid::Column.new(name: 'notes', description: 'Singlespeed'),
    'Please indicate other interests. (For example: time trial tandem triathalon r'   => Grid::Column.new(name: 'notes', description: 'Other interests'),
    'Your team or club name (please enter N/A if you do not have a team affiliation)' => Grid::Column.new(name: 'team_name', description: 'Team')
  }

  attr_reader :created
  attr_reader :updated
  attr_reader :duplicates

  def initialize(source, *options)
    if options.empty?
      options = Hash.new
    else
      options = options.first
    end

    options = {
      delimiter: ',',
      quoted: true,
      header_row: true,
      row_class: Person,
      column_map: COLUMN_MAP
    }.merge(options)

    super(source, options)

    @created = 0
    @updated = 0
    @duplicates = []
  end

  # +year+ for RaceNumbers
  # New memberships start on today, but really should start on January 1st of next year, if +year+ is next year
  def import(update_membership, year = nil)
    ActiveSupport::Notifications.instrument "import.people_file.racing_on_rails", update_membership: update_membership, import_file: import_file, rows: rows.size do
      @update_membership = update_membership
      @has_print_column = columns.any? do |column|
        column.field == :print_card
      end
      year = year.to_i if year

      assign_member_from_imported_people year

      Person.transaction do
        rows.map(&:to_hash).each do |row|
          row[:updated_by] = import_file
          logger.debug(row.inspect) if logger.debug?
          next if blank_name?(row)

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
    return @created, @updated
  end

  def find_people(row)
    people = []

    if row[:license].present? && row[:license].to_i > 0
      people = Person.where(license: row[:license])
    end

    if people.empty?
      people = Person.find_all_by_name_or_alias(first_name: row[:first_name], last_name: row[:last_name])
    end

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
    person = Person.new(updated_by: import_file)
    if year
      person.year = year
    end
    person.attributes = row
    person.save!
    @created = @created + 1
  end

  def update_person(row, person, year)
    ActiveSupport::Notifications.instrument "update.people_file.racing_on_rails", person_id: person.id, person_name: person.name

    delete_unwanted_member_from row, person
    unless person.notes.blank?
      row[:notes] = "#{person.notes}#{$INPUT_RECORD_SEPARATOR}#{row[:notes]}"
    end
    add_print_card_and_label row, person

    if year
      person.year = year
    end
    person.updated_by = import_file
    person.attributes = row

    person.save!

    @updated = @updated + 1
  end

  def create_duplicate(row, year, people)
    person = Person.new(row)

    ActiveSupport::Notifications.instrument "duplicate.people_file.racing_on_rails", person_name: person.name, people_count: people.size, people_ids: people.map(&:id)

    if year
      person.year = year
    end
    delete_unwanted_member_from row, person
    unless person.notes.blank?
      row[:notes] = "#{people.last.notes}#{$INPUT_RECORD_SEPARATOR}#{row[:notes]}"
    end
    add_print_card_and_label row, person

    row.delete :persistence_token
    row.delete :single_access_token
    row.delete :perishable_token

    duplicates << Duplicate.create!(new_attributes: Person.new(row).serializable_hash, people: people)
  end

  private

  def assign_member_from_imported_people(year)
    if @update_membership
      if year && year > Time.zone.today.year
        @member_from_imported_people = Time.zone.local(year).beginning_of_year.to_date
      else
        @member_from_imported_people = Time.zone.today.to_date
      end
      @member_to_for_imported_people = Time.zone.local(year || Time.zone.today.year).end_of_year.to_date
    end
  end

  def blank_name?(row)
    row[:first_name].blank? && row[:first_name].blank? && row[:name].blank?
  end

  def combine_categories(row)
    Person::CATEGORY_FIELDS.each do |field|
      if row[field].present?
        row[field] = row[field].gsub("\n", " ")
      end
    end
  end

  def delete_bad_date_of_birth(row)
    row.delete(:date_of_birth) if row[:date_of_birth] == 'xx'
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
        begin
          date = Time.zone.parse(row[:member_from]).to_date
          if date > person.member_from.to_date
            row[:member_from] = person.member_from
          end
        rescue ArgumentError => e
          raise ArgumentError.new("#{e}: '#{row[:member_from]}' is not a valid date. Row:\n #{row.inspect}")
        end
      end
    end
  end

  def add_print_card_and_label(row, person = nil)
    if @update_membership && !@has_print_column
      if person.nil? || (!person.member? || person.member_to.to_date < @member_to_for_imported_people.to_date)
        row[:print_card] = true
      end
    end
  end

  def import_file
    unless @import_file
      if @file
        @import_file = ImportFile.create!(name: "#{@file.path} #{Person.current.try(:name_or_login)}")
      else
        @import_file = ImportFile.create!(name: "#{Person.current.try(:name_or_login)} file")
      end
    end
    @import_file
  end

  def logger
    Rails.logger
  end
end
