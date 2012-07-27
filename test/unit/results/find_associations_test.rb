require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class FindAssociationsTest < ActiveSupport::TestCase
  setup :number_issuer
  
  def number_issuer
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline)
  end

  def test_find_associated_records_2
    event = SingleDayEvent.create!(:name => "Tabor CR")
    category = Category.find_or_create_by_name("Senior Men Pro 1/2")
    race = event.races.create!(:category => category)
    result1 = race.results.create!(
      :first_name => "Tom", :last_name => "Boonen", :team_name => "Davitamon"
    )
    result2 = race.results.create!(
      :first_name => "Paulo", :last_name => "Bettini", :team_name => "Davitamon"
    )
    assert(!result1.team.new_record?, "First result team should be saved")
    assert(!result2.team.new_record?, "Second result team should be saved")
    assert_equal(result1.team.id, result2.team.id, "Teams should have same ID")
  end

  def test_find_by_alias
    kona = FactoryGirl.create(:team, :name => "Kona")
    tonkin = FactoryGirl.create(:person, :name => "Erik Tonkin")
    Alias.create!(:team => kona, :name => 'Kona Les Gets')
    Alias.create!(:person => tonkin, :name => 'Erin Tonkin')

    # new, no aliases
    race = FactoryGirl.create(:race)
    result = race.results.create!(:place => 1, :first_name => 'Fausto', :last_name => 'Coppi', :team_name => 'Bianchi', :number => '')
    assert_equal('Fausto Coppi', result.name, 'person name')
    assert_equal('Bianchi', result.team_name, 'team name')

    # existing person, new team
    result = race.results.create!(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Bianchi', :number => '')
    result.save!
    assert_equal(tonkin.id, result.person.id, 'person id')
    assert_equal('Erik Tonkin', result.name, 'person name')
    assert_equal('Bianchi', result.team_name, 'team name')

    # new person, existing team
    result = race.results.create!(:place => 1, :first_name => 'Fausto', :last_name => 'Coppi', :team_name => 'Kona', :number => '')
    result.save!
    assert_equal(kona.id, result.team.id, 'team id')
    assert_equal('Fausto Coppi', result.name, 'person name')
    assert_equal('Kona', result.team_name, 'team name')

    # existing person, existing team
    result = race.results.create!(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Kona', :number => '')
    result.save!
    assert_equal('Erik Tonkin', result.name, 'person name')
    assert_equal('Kona', result.team_name, 'team name')

    # new person, aliased team
    result = race.results.create!(:place => 1, :first_name => 'Fausto', :last_name => 'Coppi', :team_name => 'Kona Les Gets', :number => '')
    result.save!
    assert_equal('Fausto Coppi', result.name, 'person name')
    assert_equal('Kona', result.team_name, 'team name')

    # aliased person, new team
    result = race.results.create!(:place => 1, :first_name => 'Erin', :last_name => 'Tonkin', :team_name => 'Bianchi', :number => '')
    result.save!
    assert_equal('Erik Tonkin', result.name, 'person name')
    assert_equal('Bianchi', result.team_name, 'team name')

    # aliased person, aliased team
    result = race.results.create!(:place => 1, :first_name => 'Erin', :last_name => 'Tonkin', :team_name => 'Kona Les Gets', :number => '')
    result.save!
    assert_equal('Erik Tonkin', result.name, 'person name')
    assert_equal('Kona', result.team_name, 'team name')

    # aliased person, existing team
    result = race.results.create!(:place => 1, :first_name => 'Erin', :last_name => 'Tonkin', :team_name => 'Kona', :number => '')
    result.save!
    assert_equal('Erik Tonkin', result.name, 'person name')
    assert_equal('Kona', result.team_name, 'team name')

    # existing person, aliased team
    result = race.results.create!(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Kona Les Gets', :number => '')
    result.save!
    assert_equal('Erik Tonkin', result.name, 'person name')
    assert_equal('Kona', result.team_name, 'team name')

    # no person, no team
    result = race.results.create!(:place => 1, :number => '')
    result.save!
    assert_equal(nil, result.name, 'person name')
    assert_equal(nil, result.team_name, 'team name')
  end

  def test_find_associated_records
    FactoryGirl.create(:cyclocross_discipline)
    FactoryGirl.create(:mtb_discipline)

    tonkin = FactoryGirl.create(:person, :name => "Erik Tonkin")
    FactoryGirl.create(:result, :person => tonkin)
    tonkin.aliases.create!(:name => "Eric Tonkin")
    
    # Same name, number as existing person
    kings_valley_pro_1_2_2004 = FactoryGirl.create(:race)
    results = kings_valley_pro_1_2_2004.results
    result_1 = results.create!(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :number => '104')
    assert_equal(tonkin, result_1.person, 'Person')

    # Same name, different number as existing person
    results = kings_valley_pro_1_2_2004.results
    result_2 = results.create!(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :number => '4100')
    assert_equal(tonkin, result_2.person, 'Person')
    # TODO assert warning

    # Different name, same number as existing person
    # TODO Should be warning with possibility to create! alias
    results = kings_valley_pro_1_2_2004.results
    result_3 = results.create!(:place => 1, :first_name => 'Ron', :last_name => 'Tonkin', :number => '104')
    assert_not_equal(tonkin, result_3.person, 'Person')
    assert_equal("Ron", result_3.person.first_name, 'Person')

    # Clean up from previous
    result_1.destroy
    result_2.destroy
    result_3.destroy
    Person.destroy_all(['first_name<>? and last_name=?', 'erik', 'tonkin'])
    assert_equal(1, Person.find_all_by_first_name_and_last_name('Erik','Tonkin').size, 'Erik Tonkins in database')

    # CX: Same name, different number as existing person
    tonkin.ccx_number = '555A'
    tonkin.save!
    kings_valley_2004 = FactoryGirl.create(:event)
    kings_valley_2004.discipline = 'Cyclocross'
    kings_valley_2004.save!
    results = kings_valley_pro_1_2_2004.results
    result = results.create!(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :number => '999')
    assert_equal(tonkin, result.person, 'Person')
    # TODO assert wrong number warning

    # MTB: Same name as alias for existing person, different number as existing person
    tonkin.xc_number = '70A'
    tonkin.save!
    kings_valley_2004 = kings_valley_2004
    kings_valley_2004.discipline = 'Mountain Bike'
    kings_valley_2004.save!
    results = kings_valley_pro_1_2_2004.results
    result = results.create!(:place => 1, :first_name => 'Eric', :last_name => 'Tonkin', :number => '999')
    assert_equal(tonkin, result.person, 'Person')
    # TODO assert wrong number warning

    # MTB: Same name as alias for existing person, same number as existing person
    kings_valley_2004 = kings_valley_2004
    kings_valley_2004.discipline = 'Mountain Bike'
    kings_valley_2004.save!
    results = kings_valley_pro_1_2_2004.results
    result = results.create!(:place => 1, :first_name => 'Eric', :last_name => 'Tonkin', :number => '70A')
    assert_equal(tonkin, result.person, 'Person')
  end

  def test_differentiate_people_by_license
    tonkin = FactoryGirl.create(:person, :name => "Erik Tonkin")
    tonkin.license = "12345"
    tonkin.save!

    tonkin_clone = Person.create!(:name => "Erik Tonkin", :license => "999999")

    kings_valley_pro_1_2_2004 = FactoryGirl.create(:race)
    results = kings_valley_pro_1_2_2004.results
    result = results.create!(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :license => '12345')
    assert_equal(tonkin, result.person, 'Person')

    result = results.create!(:place => 2, :first_name => 'Erik', :last_name => 'Tonkin', :license => '999999')
    assert_equal(tonkin_clone, result.person, 'Person')
  end

  def test_differentiate_people_by_number
    person = Person.create!(:name => "Joe Racer", :road_number => "600")
    person_clone = Person.create!(:name => "Joe Racer", :road_number => "550")
    person_with_same_number = Person.create!(:name => "Jenny Biker", :road_number => "600")

    senior_men = FactoryGirl.create(:category)
    results = SingleDayEvent.create!.races.create!(:category => senior_men).results
    result = results.create!(:place => 1, :first_name => 'Joe', :last_name => 'Racer', :number => "550")
    assert_equal(person_clone, result.person, 'Person')

    result = results.create!(:place => 2, :first_name => "Joe", :last_name => "Racer", :number => "600")
    assert_equal(person, result.person, 'Person')
  end

  def test_differentiate_people_by_number_ignore_different_names
    RacingAssociation.current.expects(:eager_match_on_license?).at_least_once.returns(false)
    
    person = Person.create!(:name => "Joe Racer", :updated_at => '2008-10-01')
    person.reload
    person.update_attributes(:updated_at => "2008-10-01")
    person.reload
    assert_equal_dates "2008-10-01", person.updated_at, "updated_at"
    person = Person.find(person.id)
    assert_equal_dates "2008-10-01", person.updated_at, "updated_at"
    
    person_clone = Person.create!(:name => "Joe Racer")
    Person.create!(:name => "Jenny Biker")
    person_with_same_number = Person.create!(:name => "Eddy Racer", :road_number => "600")
    senior_men = FactoryGirl.create(:category)
    SingleDayEvent.create!.races.create!(:category => senior_men).results.create!(:person => person_with_same_number)

    results = SingleDayEvent.create!.races.create!(:category => senior_men).results
    result = results.create!(:place => 1, :first_name => 'Joe', :last_name => 'Racer', :number => "550")
    assert_equal(person_clone, result.person, 'Person')

    result = results.create!(:place => 2, :first_name => "Joe", :last_name => "Racer", :number => "600")

    assert_equal 2, Person.find_all_by_name_like("Joe Racer").size, "Joe Racers"
    assert_equal(person_clone, result.person, 'Person')

    person.reload
    assert_equal_dates "2008-10-01", person.updated_at, "updated_at"

    person_clone.reload
    assert_equal_dates Time.zone.today, person_clone.updated_at, "updated_at"
  end

  def test_differentiate_people_by_number_ignore_different_names_eager_match
    RacingAssociation.current.expects(:eager_match_on_license?).at_least_once.returns(true)
    
    person = Person.create!(:name => "Joe Racer")
    Person.connection.execute "update people set updated_at = '#{Time.zone.local(2008).utc.to_s(:db)}' where id = #{person.id}"
    person.reload
    
    person_clone = Person.create!(:name => "Joe Racer")
    Person.create!(:name => "Jenny Biker")
    person_with_same_number = Person.create!(:name => "Eddy Racer", :road_number => "600")
    senior_men = FactoryGirl.create(:category)
    SingleDayEvent.create!.races.create!(:category => senior_men).results.create!(:person => person_with_same_number)

    results = SingleDayEvent.create!.races.create!(:category => senior_men).results
    result = results.create!(:place => 1, :first_name => 'Joe', :last_name => 'Racer', :number => "550")
    assert_equal(person_clone, result.person, 'Person')

    result = results.create!(:place => 2, :first_name => "Joe", :last_name => "Racer", :number => "600")
    assert_equal(person_clone, result.person, 'Person')
  end

  def test_find_people
    # TODO Add warning that numbers don't match
    tonkin = FactoryGirl.create(:person, :name => 'Erik Tonkin', :team => FactoryGirl.create(:team, :name => "Kona"))
    tonkin.race_numbers.create(:value => "104", :year => 2004)
    event = FactoryGirl.create(:event, :date => Time.zone.local(2004, 3))
    race = FactoryGirl.create(:race, :event => event)

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin')
    assert_equal([tonkin], result.find_people(event).to_a, 'first_name + last_name')

    result = race.results.build(:name => 'Erik Tonkin')
    assert_equal([tonkin], result.find_people(event).to_a, 'name')

    result = race.results.build(:last_name => 'Tonkin')
    assert_equal([tonkin], result.find_people(event).to_a, 'last_name')

    result = race.results.build(:first_name => 'Erik')
    assert_equal([tonkin], result.find_people(event).to_a, 'first_name')

    result = race.results.build(:first_name => 'Erika', :last_name => 'Tonkin')
    assert_equal([], result.find_people(event).to_a, 'first_name + last_name should not match')

    result = race.results.build(:name => 'Erika Tonkin')
    assert_equal([], result.find_people(event).to_a, 'name should not match')

    result = race.results.build(:last_name => 'onkin')
    assert_equal([], result.find_people(event).to_a, 'last_name should not match')

    result = race.results.build(:first_name => 'Erika')
    assert_equal([], result.find_people(event).to_a, 'first_name should not match')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '104')
    assert_equal([tonkin], result.find_people(event).to_a, 'road number, first_name, last_name')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '340')
    assert_equal([tonkin], result.find_people(event).to_a, 'Matson road number, first_name, last_name')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '6')
    assert_equal([tonkin], result.find_people(event).to_a, 'cross number (not in DB), first_name, last_name')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '100')
    assert_equal([tonkin], result.find_people(event).to_a, 'Different number')

    # TODO make null person and list this match as a possibility
    result = race.results.build(:first_name => 'Rhonda', :last_name => 'Tonkin', :number => '104')
    assert_equal([], result.find_people(event).to_a, 'Tonkin\'s number, different first name')

    # TODO make null person and list this match as a possibility
    result = race.results.build(:first_name => 'Erik', :last_name => 'Viking', :number => '104')
    assert_equal([], result.find_people(event).to_a, 'Tonkin\'s number, different last name')

    tonkin_clone = Person.create!(:first_name => 'Erik', :last_name => 'Tonkin')
    RaceNumber.create!(:person => tonkin_clone, :number_issuer => NumberIssuer.first, :discipline => Discipline[:road], :year => 2004, :value => '100')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin')
    assert_same_elements([tonkin, tonkin_clone], result.find_people(event).to_a, 'Same names, no numbers')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '6')
    assert_same_elements([tonkin, tonkin_clone], result.find_people(event).to_a, 'Same names, bogus numbers')

    result = race.results.build(:last_name => 'Tonkin')
    assert_same_elements([tonkin, tonkin_clone], result.find_people(event).to_a, 'Same last name')

    result = race.results.build(:first_name => 'Erik')
    assert_same_elements([tonkin, tonkin_clone], result.find_people(event).to_a, 'Same names, bogus numbers')

    result = race.results.build(:number => '6')
    assert_equal([], result.find_people(event).to_a, 'ccx number (not in DB)')

    result = race.results.build(:number => '104')
    assert_equal([tonkin], result.find_people(event).to_a, 'road number, first_name, last_name')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '104')
    assert_equal([tonkin], result.find_people(event).to_a, 'road number, first_name, last_name')

    result = race.results.build(:number => '100')
    assert_equal([tonkin_clone], result.find_people(event).to_a, 'road number')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '100')
    assert_equal([tonkin_clone], result.find_people(event).to_a, 'road number, first_name, last_name')

    # team_name -- consider last
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Kona')
    assert_equal([tonkin], result.find_people(event).to_a, 'first_name, last_name, team')

    # TODO: change to possible match
    result = race.results.build(:first_name => 'Erika', :last_name => 'Tonkin', :team_name => 'Kona')
    assert_equal([], result.find_people(event).to_a, 'wrong first_name, last_name, team')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Kona', :number => '104')
    assert_equal([tonkin], result.find_people(event).to_a, 'first_name, last_name, team, number')

    result = race.results.build(:last_name => 'Tonkin', :team_name => 'Kona')
    assert_equal([tonkin], result.find_people(event).to_a, 'last_name, team')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => '')
    assert_same_elements([tonkin, tonkin_clone], result.find_people(event).to_a, 'first_name, last_name, blank team')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Camerati')
    assert_equal([tonkin_clone], result.find_people(event).to_a, 'first_name, last_name, wrong team')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Camerati', :number => '987')
    assert_equal([tonkin_clone], result.find_people(event).to_a, 'first_name, last_name, wrong team, wrong number')

    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    vanilla.aliases.create!(:name => "Vanilla Bicycles")
    tonkin_clone.team = vanilla
    tonkin_clone.save!

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Vanilla Bicycles')
    assert_equal([tonkin_clone], result.find_people(event).to_a, 'first_name, last_name + team alias should match')

    result = race.results.build
    assert_equal([], result.find_people(event).to_a, 'no person, team, nor number')

    result = race.results.build(:team_name => 'Astana Wurth')
    assert_equal([], result.find_people(event).to_a, 'wrong team only')

    # rental numbers
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '60')
    assert_same_elements([tonkin, tonkin_clone], result.find_people(event).to_a, 'rental number')

    result = race.results.build(:first_name => '', :last_name => '')
    assert_same_elements([], result.find_people(event).to_a, 'blank name with no blank names')

    blank_name_person = Person.create!(:name => '', :dh_number => '100')
    result = race.results.build(:first_name => '', :last_name => '')
    assert_same_elements([blank_name_person], result.find_people(event).to_a, 'blank names')

    # Add exact dupes with same numbers
    # Test numbers from different years or disciplines
  end

  def test_assign_results_to_existing_person_with_same_name_instead_of_creating_a_new_one
    tonkin = FactoryGirl.create(:person, :name => "Erik Tonkin")
    FactoryGirl.create(:result, :person => tonkin)
    new_tonkin = FactoryGirl.create(:person, :name => "Erik Tonkin")
    assert_equal(2, Person.find_all_by_name("Erik Tonkin").size, "Should have 2 Tonkins")
    assert_equal(2, Person.find_all_by_name_or_alias(:first_name => "Erik", :last_name => "Tonkin").size, "Should have 2 Tonkins")

    # A very old result
    category = FactoryGirl.create(:category)
    SingleDayEvent.create!(:date => Date.new(1980)).races.create!(:category => category).results.create!(:person => new_tonkin)

    race = FactoryGirl.create(:race)
    result = race.results.create!(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin')

    assert_equal(2, Person.find_all_by_name("Erik Tonkin").size, "Should not create! new Tonkin")
    assert_equal(tonkin, result.person, "Should use person with most recent result")
  end

  def test_most_recent_person_if_no_results
    tonkin = FactoryGirl.create(:person, :name => "Erik Tonkin")
    new_tonkin = Person.create!(:name => "Erik Tonkin")
    assert_equal(2, Person.find_all_by_name("Erik Tonkin").size, "Should have 2 Tonkins")
    assert_equal(2, Person.find_all_by_name_or_alias("Erik", "Tonkin").size, "Should have 2 Tonkins")

    # Force magic updated_at column to past time
    Person.connection.execute("update people set updated_at = '2009-10-05 16:18:22' where id=#{tonkin.id}")

    new_tonkin.city = "Brussels"
    new_tonkin.save!

    race = FactoryGirl.create(:race)
    result = race.results.create!(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin')

    assert_equal(2, Person.find_all_by_name("Erik Tonkin").size, "Should not create! new Tonkin")
    assert_equal(new_tonkin, result.person, "Should use most recently-updated person if can't decide otherwise")
  end
  
  def test_find_people_among_duplicates
    FactoryGirl.create(:cyclocross_discipline)
    
    Timecop.freeze(Date.new(Time.zone.today.year, 6)) do
      Person.create!(:name => "Mary Yax").race_numbers.create!(:value => "157")

      jt_1 = Person.create!(:name => "John Thompson")
      jt_2 = Person.create!(:name => "John Thompson")
      jt_2.race_numbers.create!(:value => "157", :discipline => Discipline[:cyclocross])

      # Bad discipline name—should cause name to not match
      senior_men = FactoryGirl.create(:category)
      cx_race = SingleDayEvent.create!(:discipline => "Cyclocross").races.create!(:category => senior_men)
      result = cx_race.results.create!(:place => 1, :first_name => 'John', :last_name => 'Thompson', :number => "157")
      assert_equal jt_2, result.person, "Should assign person based on correct discipline number"
    end
  end

  def test_multiple_scores_for_same_race
    competition = Competition.create!(:name => 'KOM')
    cx_a = FactoryGirl.create(:category)
    competition_race = competition.races.create!(:category => cx_a)
    tonkin = FactoryGirl.create(:person)
    competition_result = competition_race.results.create!(:person => tonkin, :points => 5)

    race = FactoryGirl.create(:race)
    tonkin = FactoryGirl.create(:person)
    source_result = race.results.create!(:person => tonkin)

    assert(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 10))

    jack_frost_pro_1_2 = FactoryGirl.create(:race)
    source_result = jack_frost_pro_1_2.results.build(:person => tonkin)
    assert(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 10))

    source_result = jack_frost_pro_1_2.results.build(:person => tonkin)
    assert_nil(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 10))

    # Need a lot more tests
    expert_junior_men = FactoryGirl.create(:category)
    competition_race = competition.races.create!(:category => expert_junior_men)
    race = race.event.races.create!(:category => expert_junior_men)
    vanilla = FactoryGirl.create(:team)
    source_result = jack_frost_pro_1_2.results.build(:team => vanilla)
    competition_result = competition_race.results.create!(:team => vanilla)
    assert(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 10))
    source_result = jack_frost_pro_1_2.results.build(:team => vanilla)
    assert_not_nil(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 2))
    jack_frost_masters_35_plus_women = FactoryGirl.create(:race)
    source_result = jack_frost_masters_35_plus_women.results.build(:team => vanilla)
    assert(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 4))
  end

  def test_do_not_match_blank_licenses
    blank_license_person = Person.create!(:name => 'Rocket, The', :license => "")
    weaver = FactoryGirl.create(:person, :name => "Ryan Weaver", :first_name => 'Ryan', :last_name => 'Weaver')
    race = FactoryGirl.create(:race)
    result = race.results.create!(:first_name => 'Ryan', :last_name => 'Weaver')
    assert_same_elements([weaver], result.find_people(result.event).to_a, "blank license shouldn't match anything")
  end
end
