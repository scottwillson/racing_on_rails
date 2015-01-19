require "test_helper"

# :stopdoc:
class PersonFileTest < ActiveSupport::TestCase
  test "import" do
    FactoryGirl.create(:discipline, name: "Cyclocross")
    FactoryGirl.create(:discipline, name: "Downhill")
    FactoryGirl.create(:discipline, name: "Mountain Bike")
    FactoryGirl.create(:discipline, name: "Road")
    FactoryGirl.create(:number_issuer)

    # Pre-existing people
    Person.create!(
      last_name:'Abers',
      first_name: 'Brian',
      gender: 'M',
      email:'brian@sportslabtraining.com',
      member_from: '2004-02-23',
      member_to: Date.new(Time.zone.today.year + 1, 12, 31),
      date_of_birth: '1965-10-02',
      notes: 'Existing notes',
      road_number: '824',
      dh_number: "117"
    )

    rene = Person.create!(
      last_name:'Babi',
      first_name: 'Rene',
      gender: 'M',
      email:'rbabi@rbaintl.com',
      member_from: '2000-01-01',
      team_name: 'RBA Cycling Team',
      road_category: '4',
      road_number: '190A',
      date_of_birth: '1899-07-14'
    )

    scott = Person.create!(
      last_name:'Seaton',
      first_name: 'Scott',
      gender: 'M',
      email:'sseaton@bendcable.com',
      member_from: '2000-01-01',
      team_name: 'EWEB',
      road_category: '3',
      date_of_birth: '1959-12-09',
      license: "1516"
    )
    scott.race_numbers.create!(value: '422', year: Time.zone.today.year - 1)
    number = RaceNumber.where(person_id: scott.id, value: "422").first
    assert_not_nil(number, "Scott\'s previous road number")
    assert_equal(Discipline[:road], number.discipline, 'Discipline')

    # Dupe Scott Seaton should be skipped because of different license
    Person.create!(
      last_name:'Seaton',
      first_name: 'Scott'
    )

    path = "#{Rails.root}/test/fixtures/membership/upload.xlsx"
    people = PeopleFile.new(path).import(true)

    assert_equal([2, 3], people, 'Number of people created and updated')

    all_quinn_jackson = Person.find_all_by_name('quinn jackson')
    assert_equal(1, all_quinn_jackson.size, 'Quinn Jackson in database after import')
    quinn_jackson = all_quinn_jackson.first
    assert_equal('M', quinn_jackson.gender, 'Quinn Jackson gender')
    assert_equal('quinn3769@yahoo.com', quinn_jackson.email, 'Quinn Jackson email')
    assert_equal_dates('2006-04-19', quinn_jackson.member_from, 'Quinn Jackson member from')
    assert_equal_dates(Time.zone.now.end_of_year, quinn_jackson.member_to, 'Quinn Jackson member to')
    assert_equal_dates('1975-08-01', quinn_jackson.date_of_birth, 'Birth date')
    assert_equal('rm', quinn_jackson.notes, 'Quinn Jackson notes')
    assert_equal('1416 SW Hume Street', quinn_jackson.street, 'Quinn Jackson street')
    assert_equal('Portland', quinn_jackson.city, 'Quinn Jackson city')
    assert_equal('OR', quinn_jackson.state, 'Quinn Jackson state')
    assert_equal('97219', quinn_jackson.zip, 'Quinn Jackson ZIP')
    assert_equal('503-768-3822', quinn_jackson.home_phone, 'Quinn Jackson phone')
    assert_equal('nurse', quinn_jackson.occupation, 'Quinn Jackson occupation')
    assert_equal('120', quinn_jackson.xc_number(true), 'quinn_jackson xc number')
    assert_not_nil quinn_jackson.created_by, "Person#created_by should be set"
    assert_not_nil quinn_jackson.updated_by_person, "Person#updated_by_person should be set"
    number = quinn_jackson.race_numbers.detect { |n| n.value == "120" }
    assert(number.updated_by_person.name["membership/upload.xlsx"], "updated_by_person expected to include file name but was #{number.updated_by_person.try(:name)}")
    assert(!quinn_jackson.print_card?, 'quinn_jackson.print_card? after import')

    all_abers = Person.find_all_by_name('Brian Abers')
    assert_equal(1, all_abers.size, 'Brian Abers in database after import')
    brian_abers = all_abers.first
    assert_equal('M', brian_abers.gender, 'Brian Abers gender')
    assert_equal('thekilomonster@verizon.net', brian_abers.email, 'Brian Abers email')
    assert_equal_dates('2004-02-23', brian_abers.member_from, 'Brian Abers member from')
    assert_equal_dates(Date.new(Time.zone.today.year, 12, 31), brian_abers.member_to, 'Brian Abers member to')
    assert_equal_dates('1958-03-05', brian_abers.date_of_birth, 'Birth date')
    assert_equal("Existing notes", brian_abers.notes, 'Brian Abers notes')
    assert_equal('5735 SW 198th Ave', brian_abers.street, 'Brian Abers street')
    road_numbers = RaceNumber.where(person: brian_abers, discipline: Discipline[:road], year: RacingAssociation.current.year)
    assert_equal(2, road_numbers.count, 'Brian Abers road_numbers')
    assert road_numbers.any? { |n| n.value == "824" }, "Should preseve Brian Abers road number"
    assert road_numbers.any? { |n| n.value == "825" }, "Should add Brian Abers new road number"
    assert_equal(nil, brian_abers.dh_number, 'Brian Abers dh_number should be removed')
    assert(!brian_abers.print_card?, 'brian_abers.print_card? after import')

    all_heidi_babi = Person.find_all_by_name('heidi babi')
    assert_equal(1, all_heidi_babi.size, 'Heidi Babi in database after import')
    heidi_babi = all_heidi_babi.first
    assert_equal('F', heidi_babi.gender, 'Heidi Babi gender')
    assert_equal('hbabi77@hotmail.com', heidi_babi.email, 'Heidi Babi email')
    assert_equal_dates(Time.zone.today, heidi_babi.member_from, 'Heidi Babi member from')
    assert_equal_dates(Date.new(Time.zone.today.year, 12, 31), heidi_babi.member_to, 'Heidi Babi member to')
    assert_equal_dates('1973-03-12', heidi_babi.date_of_birth, 'Birth date')
    assert_equal(nil, heidi_babi.notes, 'Heidi Babi notes')
    assert_equal('11408 NE 102ND ST', heidi_babi.street, 'Heidi Babi street')
    assert_equal('360-896-3827', heidi_babi.home_phone, 'Heidi home phone')
    assert_equal('360-696-9272', heidi_babi.work_phone, 'Heidi work phone')
    assert_equal('360-696-9398', heidi_babi.cell_fax, 'Heidi cell/fax')
    assert(heidi_babi.print_card?, 'heidi_babi.print_card? after import')

    all_rene_babi = Person.find_all_by_name('rene babi')
    assert_equal(1, all_rene_babi.size, 'Rene Babi in database after import')
    rene_babi = all_rene_babi.first
    assert_equal('M', rene_babi.gender, 'Rene Babi gender')
    assert_equal('rbabi@rbaintl.com', rene_babi.email, 'Rene Babi email')
    assert_equal_dates('2000-01-01', rene_babi.member_from, 'Rene Babi member from')
    assert_equal_dates(Date.new(Time.zone.today.year, 12, 31), rene_babi.member_to, 'Rene Babi member to')
    assert_equal_dates('1980-08-04', rene_babi.date_of_birth, 'Birth date')
    assert_equal(nil, rene_babi.notes, 'Rene Babi notes')
    assert_equal('1431 SE Columbia Way', rene_babi.street, 'Rene Babi street')
    assert(rene_babi.print_card?, 'rene_babi.print_card? after import')
    assert_equal('190A', rene_babi.road_number, 'Rene road_number')

    all_scott_seaton = Person.find_all_by_name('scott seaton')
    assert_equal(2, all_scott_seaton.size, 'Scott Seaton in database after import')
    scott_seaton = all_scott_seaton.detect { |p| p.license == "1516"}
    assert_equal('M', scott_seaton.gender, 'Scott Seaton gender')
    assert_equal('sseaton@bendcable.com', scott_seaton.email, 'Scott Seaton email')
    assert_equal_dates('2000-01-01', scott_seaton.member_from, 'Scott Seaton member from')
    assert_equal_dates(Date.new(Time.zone.today.year, 12, 31), scott_seaton.member_to, 'Scott Seaton member to')
    assert_equal_dates('1976-01-10', scott_seaton.date_of_birth, 'Birth date')
    assert_equal(nil, scott_seaton.notes, 'Scott Seaton notes')
    assert_equal('1654 NW 2nd', scott_seaton.street, 'Scott Seaton street')
    assert_equal('Bend', scott_seaton.city, 'Scott Seaton city')
    assert_equal('OR', scott_seaton.state, 'Scott Seaton state')
    assert_equal('97701', scott_seaton.zip, 'Scott Seaton ZIP')
    assert_equal('541-389-3721', scott_seaton.home_phone, 'Scott Seaton phone')
    assert_equal('firefighter', scott_seaton.occupation, 'Scott Seaton occupation')
    assert_equal("Hutch's Bend", scott_seaton.team_name, 'Scott Seaton team should be updated')
    assert(!scott_seaton.print_card?, 'sautter.print_card? after import')

    scott.race_numbers.create(value: '422', year: Time.zone.today.year - 1)
    number = RaceNumber.where(person_id: scott.id, value: "422").first
    assert_not_nil(number, "Scott\'s previous road number")
    assert_equal(Discipline[:road], number.discipline, 'Discipline')
  end

  test "import duplicates" do
    existing_person_with_login = FactoryGirl.create(:person_with_login, name: "Erik Tonkin")
    existing_person = FactoryGirl.create(:person, name: "Erik Tonkin")

    file = File.new("#{Rails.root}/test/fixtures/membership/duplicates.xlsx")
    people_file = PeopleFile.new(file)

    people_file.import(true)

    assert_equal(1, people_file.created, 'Number of people created')
    assert_equal(0, people_file.updated, 'Number of people updated')
    assert_equal(1, people_file.duplicates.size, 'Number of duplicates')

    duplicate = people_file.duplicates.first
    assert existing_person.in?(duplicate.people), "Should include person with same name"
    assert existing_person_with_login.in?(duplicate.people), "Should include person with same name"
    assert_equal "Portland", duplicate.new_attributes["city"], "city"
    assert duplicate.new_attributes.values.none?(&:nil?), "Should be no nil values in #{duplicate.new_attributes}"
  end
end
