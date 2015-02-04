require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class RaceNumberTest < ActiveSupport::TestCase
  test "defaults" do
    FactoryGirl.create(:number_issuer, name: "AVC")
    association_number_issuer = FactoryGirl.create(:number_issuer, name: "CBRA")

    FactoryGirl.create(:discipline, name: "Road")
    track = FactoryGirl.create(:discipline, name: "Track")
    FactoryGirl.create(:discipline, name: "Cyclocross")

    racing_association = RacingAssociation.current
    racing_association.update! default_discipline: "Track"

    person = FactoryGirl.create(:person)
    race_number = RaceNumber.create!(value: '999', person: person)
    assert_equal RacingAssociation.current.effective_year, race_number.year, 'year default'
    assert_equal track, race_number.discipline, 'year discipline'
    assert_equal association_number_issuer, race_number.number_issuer, 'number issuer default'
  end

  test "create" do
    FactoryGirl.create(:number_issuer)
    road = FactoryGirl.create(:discipline, name: "Road")
    track = FactoryGirl.create(:discipline, name: "Track")
    alice = FactoryGirl.create(:person)
    molly = FactoryGirl.create(:person)
    elkhorn = NumberIssuer.create!(name: 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(person: alice, value: 'A103', year: 2001, number_issuer: elkhorn, discipline: road, updated_by: molly)
    assert_equal molly, race_number.created_by, "created_by"
    assert_equal molly, race_number.updated_by_person, "update_by"
    assert_equal(alice, race_number.person, 'New number person')
    assert_equal(2001, race_number.year, 'New number year')
    assert_equal(elkhorn, race_number.number_issuer, 'New number_issuer person')
    assert_equal(road, race_number.discipline, 'New number discipline')

    # One field different
    RaceNumber.create!(person: alice, value: 'A104', year: 2001, number_issuer: elkhorn, discipline: road)
    RaceNumber.create!(person: alice, value: 'A103', year: 2002, number_issuer: elkhorn, discipline: road)
    obra = NumberIssuer.find_or_create_by(name: 'CBRA')
    RaceNumber.create!(person: alice, value: 'A103', year: 2001, number_issuer: obra, discipline: road)
    RaceNumber.create!(person: alice, value: 'A103', year: 2001, number_issuer: elkhorn, discipline: track)

    # dupes OK if different person
    assert(RaceNumber.new(person: alice, value: '999', year: 2001, number_issuer: elkhorn, discipline: road).valid?, 'Same person, same value')
    assert(RaceNumber.new(person: molly, value: '999', year: 2001, number_issuer: elkhorn, discipline: road).valid?, 'Different people, same value')

    # invalid because missing fields
    assert(!RaceNumber.new(person: alice, year: 2001, number_issuer: elkhorn, discipline: road).valid?, 'No value')
    assert(!RaceNumber.new(person: alice, value: '', year: 2001, number_issuer: elkhorn, discipline: road).valid?, 'Blank value')

    # No person ID invalid
    no_person = RaceNumber.new(value: 'A103', year: 2001, number_issuer: elkhorn, discipline: road)
    assert !no_person.valid?

    # Defaults
    race_number = RaceNumber.new(person: alice, value: 'A1', number_issuer: elkhorn, discipline: road)
    assert(race_number.valid?, 'No year')
    race_number.save!

    race_number = RaceNumber.new(person: alice, value: '9000', year: 2001, discipline: road)
    assert(race_number.valid?, "no issuer: #{race_number.errors.full_messages}")
    race_number.save!

    race_number = RaceNumber.new(person: alice, value: '9103', year: 2001, number_issuer: elkhorn)
    assert(race_number.valid?, "No discipline: #{race_number.errors.full_messages}")
    race_number.save!
  end

  test "cannot create exact same number for person" do
    alice = FactoryGirl.create(:person)
    obra = NumberIssuer.find_or_create_by(name: 'CBRA')
    cyclocross = FactoryGirl.create(:discipline, name: "Cyclocross")
    FactoryGirl.create(:discipline, name: "Road")

    RaceNumber.create!(person: alice, value: '876', year: 2001, number_issuer: obra, discipline: cyclocross)
    number = RaceNumber.create(person: alice, value: '876', year: 2001, number_issuer: obra, discipline: cyclocross)
    assert(!number.valid?, "Should not be able to create two of the exact same numbers")
  end

  test "rental" do
    alice = FactoryGirl.create(:person)
    racing_association = RacingAssociation.current
    racing_association.rental_numbers = 51..99
    racing_association.save!
    FactoryGirl.create(:number_issuer)
    road = FactoryGirl.create(:discipline, name: "Road")
    elkhorn = NumberIssuer.create!(name: 'Elkhorn Classic SR')

    assert(RaceNumber.new(person: alice, value: '10', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: '11', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: ' 78', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: '99', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: '100', year: 2001, number_issuer: elkhorn, discipline: road).valid?)

    assert(RaceNumber.rental?(nil), 'Nil number is rental')
    assert(RaceNumber.rental?(''), 'Blank number is rental')
    assert(!RaceNumber.rental?(' 9 '), '9 not rental')
    assert(!RaceNumber.rental?('11'), '11 is not a rental')
    assert(RaceNumber.rental?('99'), '99 is rental')
    assert(!RaceNumber.rental?('11', Discipline[:downhill]), '11 is rental')
    assert(!RaceNumber.rental?('99', Discipline[:mountain_bike]), '99 is rental')
    assert(!RaceNumber.rental?('100'), '100 not rental')
    assert(!RaceNumber.rental?('A100'), 'A100 not rental')
    assert(!RaceNumber.rental?('A50'), 'A50 not rental')
    assert(!RaceNumber.rental?('50Z'), '50Z not rental')

    assert(RaceNumber.new(person: alice, value: '10', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: '11', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    race_number = RaceNumber.new(person: alice, value: ' 78', year: 2001, number_issuer: elkhorn, discipline: road)
    assert race_number.valid?, race_number.errors.full_messages.join(", ")
    assert(RaceNumber.new(person: alice, value: '99', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: '100', year: 2001, number_issuer: elkhorn, discipline: road).valid?)

    assert(RaceNumber.rental?(nil), 'Nil number rental')
    assert(RaceNumber.rental?(''), 'Blank number rental')
    assert(!RaceNumber.rental?(' 9 '), '9 not rental')
    assert(!RaceNumber.rental?('11'), '11 is rental')
    assert(RaceNumber.rental?('99'), '99 is rental')
    assert(!RaceNumber.rental?('100'), '100 not rental')
    assert(!RaceNumber.rental?('A100'), 'A100 not rental')
    assert(!RaceNumber.rental?('A50'), 'A50 not rental')
    assert(!RaceNumber.rental?('50Z'), '50Z not rental')
  end

  test "rental no rental numbers" do
    alice = FactoryGirl.create(:person)
    racing_association = RacingAssociation.current
    racing_association.rental_numbers = nil
    racing_association.save!
    FactoryGirl.create(:number_issuer)
    road = FactoryGirl.create(:discipline, name: "Road")
    elkhorn = NumberIssuer.create!(name: 'Elkhorn Classic SR')

    assert(RaceNumber.new(person: alice, value: '10', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: '11', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: ' 78', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: '99', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: '100', year: 2001, number_issuer: elkhorn, discipline: road).valid?)

    assert(!RaceNumber.rental?(nil), 'Nil number is rental')
    assert(!RaceNumber.rental?(''), 'Blank number is rental')
    assert(!RaceNumber.rental?(' 9 '), '9 not rental')
    assert(!RaceNumber.rental?('11'), '11 is not a rental')
    assert(!RaceNumber.rental?('99'), '99 is rental')
    assert(!RaceNumber.rental?('11', Discipline[:downhill]), '11 is rental')
    assert(!RaceNumber.rental?('99', Discipline[:mountain_bike]), '99 is rental')
    assert(!RaceNumber.rental?('100'), '100 not rental')
    assert(!RaceNumber.rental?('A100'), 'A100 not rental')
    assert(!RaceNumber.rental?('A50'), 'A50 not rental')
    assert(!RaceNumber.rental?('50Z'), '50Z not rental')

    assert(RaceNumber.new(person: alice, value: '10', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: '11', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    race_number = RaceNumber.new(person: alice, value: ' 78', year: 2001, number_issuer: elkhorn, discipline: road)
    assert race_number.valid?, race_number.errors.full_messages.join(", ")
    assert(RaceNumber.new(person: alice, value: '99', year: 2001, number_issuer: elkhorn, discipline: road).valid?)
    assert(RaceNumber.new(person: alice, value: '100', year: 2001, number_issuer: elkhorn, discipline: road).valid?)

    assert(!RaceNumber.rental?(nil), 'Nil number not rental')
    assert(!RaceNumber.rental?(''), 'Blank number not rental')
    assert(!RaceNumber.rental?(' 9 '), '9 not rental')
    assert(!RaceNumber.rental?('11'), '11 is not a rental')
    assert(!RaceNumber.rental?('99'), '99 is not a rental')
    assert(!RaceNumber.rental?('100'), '100 not rental')
    assert(!RaceNumber.rental?('A100'), 'A100 not rental')
    assert(!RaceNumber.rental?('A50'), 'A50 not rental')
    assert(!RaceNumber.rental?('50Z'), '50Z not rental')
  end

  test "create bmx" do
    alice = FactoryGirl.create(:person)
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, name: "Road")
    bmx = FactoryGirl.create(:discipline, name: "BMX")
    elkhorn = NumberIssuer.create!(name: 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(person: alice, value: 'A103', year: 2001, number_issuer: elkhorn, discipline: bmx)
    assert_equal(alice, race_number.person, 'New number person')
    assert_equal(2001, race_number.year, 'New number year')
    assert_equal(elkhorn, race_number.number_issuer, 'New number_issuer person')
    assert_equal(bmx, race_number.discipline, 'New number discipline')
  end

  test "destroy" do
    alice = FactoryGirl.create(:person)
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, name: "Road")
    elkhorn = NumberIssuer.create!(name: 'Elkhorn Classic SR')
    RaceNumber.create!(person: alice, value: 'A103', year: 2001, number_issuer: elkhorn)
    alice.results.clear
    alice.destroy
    assert(!RaceNumber.exists?(person_id: alice.id, value: 'A103'), "Shoud delete person")
  end

  test "gender" do
    alice = FactoryGirl.create(:person)
    tonkin = FactoryGirl.create(:person)
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, name: "Road")

    RacingAssociation.current.gender_specific_numbers = false

    race_number = RaceNumber.new(person: alice, value: '9103')
    assert(race_number.valid?, "Default non-gender-specific number: #{race_number.errors.full_messages}")

    race_number = RaceNumber.create!(person: tonkin, value: '200')
    assert(race_number.valid?, "Default non-gender-specific number: #{race_number.errors.full_messages}")

    race_number = RaceNumber.new(person: alice, value: '200')
    assert(race_number.valid?, 'Dupe number for different gender should be valid')
  end

  test "gender alt" do
    alice = FactoryGirl.create(:person)
    FactoryGirl.create(:person)
    molly = FactoryGirl.create(:person)

    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, name: "Road")

    RacingAssociation.current.gender_specific_numbers = true

    race_number = RaceNumber.create!(person: alice, value: '200')
    assert(race_number.valid?, 'Dupe number for different gender should be valid')

    race_number = RaceNumber.new(person: molly, value: '200')
    assert(race_number.valid?, 'Dupe number for same gender should be valid')
  end

  test "value should be a string" do
    assert_equal "4", RaceNumber.new(value: 4).value, "value"
  end
end
