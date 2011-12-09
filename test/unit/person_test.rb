require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PersonTest < ActiveSupport::TestCase
  def test_save
    assert_nil(Person.find_by_last_name("Hampsten"), "Hampsten should not be in DB")
    assert_nil(Team.find_by_name("7-11"), "7-11 should not be in DB")
    
    person = Person.new(:last_name => "Hampsten")
    team = Team.new(:name => "7-11")
    
    person.team = team
    person.save!
    
    person_from_db = Person.find_by_last_name("Hampsten")
    assert_not_nil(person_from_db, "Hampsten should  be  DB")
    assert_not_nil(Team.find_by_name("7-11"), "7-11 should be in DB")
    assert_equal(person.team, person_from_db.team, "person.team")
    person.reload
    assert_equal(person.team, person_from_db.team, "person.team")
    assert(!person.team.new_record?, "team.new_record")
    assert(!person_from_db.new_record?, "person_from_db.new_record")
  end

  def test_save_existing_team
    assert_nil(Person.find_by_last_name("Hampsten"), "Hampsten should not be in DB")
    FactoryGirl.create(:team, :name => "Vanilla").aliases.create!(:name => "Vanilla Bicycles")
    assert_not_nil(Team.find_by_name("Vanilla"), "Vanilla should be in DB")
    
    person = Person.new(:last_name => "Hampsten")
    team = Team.new(:name => "Vanilla")
    
    person.team = team
    person.save!
    assert_equal(person.team, Team.find_by_name("Vanilla"), 'Vanilla from DB')
    person.reload
    assert_equal(person.team, Team.find_by_name("Vanilla"), 'Vanilla from DB')
  end
  
  def test_team_name_should_preserve_aliases
    team = Team.create!(:name => "Sorella Forte Elite Team")
    event = SingleDayEvent.create!(:date => 1.years.ago)
    senior_men = FactoryGirl.create(:category)
    result = event.races.create!(:category => senior_men).results.create!(:team => team)
    team.aliases.create!(:name => "Sorella Forte")
    assert_equal(0, team.names(true).size, "names")
    assert_equal(1, team.aliases(true).size, "Aliases")
    assert_equal(["Sorella Forte"], team.aliases.map(&:name).sort, "Team aliases")
    
    person = Person.new(:name => "New Person", :team_name => "Sorella Forte")
    person.save!

    assert_equal(1, Team.count(:conditions => { :name => "Sorella Forte Elite Team"} ), "Should have one Sorella Forte in database")
    team = Team.find_by_name("Sorella Forte Elite Team")
    assert_equal(0, team.names(true).size, "names")
    assert_equal(1, team.aliases(true).size, "Aliases")
    assert_equal(["Sorella Forte"], team.aliases.map(&:name).sort, "Team aliases")
  end

  def test_merge
    number_issuer = FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, :name => "Road")
    
    person_to_keep = FactoryGirl.create(
      :person_with_login,
      :login => "molly",
      :city => "Berlin",
      :road_number => "202",
      :member_from => Time.zone.local(1996)
    )
    person_to_keep.aliases.create!(:name => "Mollie Cameron")
    person_to_keep_old_password = person_to_keep.crypted_password
    FactoryGirl.create(:result, :person => person_to_keep)
    FactoryGirl.create(:result, :person => person_to_keep)
    FactoryGirl.create(:result, :person => person_to_keep)

    person_to_merge = FactoryGirl.create(:person, :member_to => Time.zone.local(2008, 12, 31), :street => "123 Holly", :license => "7123811")
    person_to_merge.race_numbers.create!(:value => "102")
    person_to_merge.race_numbers.create!(:year => 2004, :value => "104")
    FactoryGirl.create(:result, :person => person_to_merge)
    FactoryGirl.create(:result, :person => person_to_merge)
    person_to_merge.aliases.create!(:name => "Eric Tonkin")
    
    assert_not_nil(Person.find_by_first_name_and_last_name(person_to_keep.first_name, person_to_keep.last_name), "#{person_to_keep.name} should be in DB")
    assert_equal(3, Result.find_all_by_person_id(person_to_keep.id).size, "Molly's results")
    assert_equal(1, Alias.find_all_by_person_id(person_to_keep.id).size, "Mollys's aliases")
    assert_equal(1, person_to_keep.race_numbers.count, "Target person's race numbers")
    assert_equal("202", person_to_keep.race_numbers.first.value, "Target person's race number value")
    association = NumberIssuer.find_by_name(RacingAssociation.current.short_name)
    assert_equal(association, person_to_keep.race_numbers.first.number_issuer, "Target person's race number issuer")
    
    assert_not_nil(Person.find_by_first_name_and_last_name(person_to_merge.first_name, person_to_merge.last_name), "#{person_to_merge.name} should be in DB")
    assert_equal(2, Result.find_all_by_person_id(person_to_merge.id).size, "Tonkin's results")
    assert_equal(1, Alias.find_all_by_person_id(person_to_merge.id).size, "Tonkin's aliases")
    assert_equal(2, person_to_merge.race_numbers.count, "Merging person's race numbers")
    race_numbers = person_to_merge.race_numbers.sort
    assert_equal("102", race_numbers.first.value, "Merging person's race number value")
    assert_equal(association, race_numbers.first.number_issuer, "Merging person's race number issuer")
    assert_equal("104", race_numbers.last.value, "Merging person's race number value")
    elkhorn = NumberIssuer.create!(:name => "Elkhorn")
    race_numbers.last.number_issuer = elkhorn
    race_numbers.last.save!
    assert_equal(elkhorn, race_numbers.last.number_issuer, "Merging person's race number issuer")
    
    promoter_events = [ Event.create!(:promoter => person_to_keep), Event.create!(:promoter => person_to_merge) ]
    
    person_to_keep.merge(person_to_merge)
    
    person_to_keep.reload
    assert_not_nil(Person.find_by_first_name_and_last_name(person_to_keep.first_name, person_to_keep.last_name), "#{person_to_keep.name} should be in DB")
    assert_equal(5, Result.find_all_by_person_id(person_to_keep.id).size, "Molly's results")
    aliases = Alias.find_all_by_person_id(person_to_keep.id)
    erik_alias = aliases.detect{|a| a.name == person_to_merge.name }
    assert_not_nil(erik_alias, "Molly should have merged person's name as an alias")
    assert_equal(3, Alias.find_all_by_person_id(person_to_keep.id).size, "Molly's aliases")
    assert_equal(3, person_to_keep.race_numbers(true).size, "Target person's race numbers: #{person_to_keep.race_numbers.map(&:value)}")
    race_numbers = person_to_keep.race_numbers.sort
    assert_equal("102", race_numbers[0].value, "Person's race number value")
    assert_equal(association, race_numbers[0].number_issuer, "Person's race number issuer")
    assert_equal("104", race_numbers[1].value, "Person's race number value")
    assert_equal(elkhorn, race_numbers[1].number_issuer, "Person's race number issuer")
    assert_equal("202", race_numbers[2].value, "Person's race number value")
    assert_equal(association, race_numbers[2].number_issuer, "Person's race number issuer")

    assert_nil(Person.find_by_first_name_and_last_name(person_to_merge.first_name, person_to_merge.last_name), "#{person_to_merge.name} should not be in DB")
    assert_equal(0, Result.find_all_by_person_id(person_to_merge.id).size, "Tonkin's results")
    assert_equal(0, Alias.find_all_by_person_id(person_to_merge.id).size, "Tonkin's aliases")
    assert_same_elements(promoter_events, person_to_keep.events(true), "Should merge promoter events")
    
    assert_equal "molly", person_to_keep.login, "Should preserve login"
    assert_equal person_to_keep_old_password, person_to_keep.crypted_password, "Should preserve password"

    assert_equal_dates Time.zone.local(1996).to_date, person_to_keep.member_from, "member_from"
    assert_equal_dates Time.zone.now.end_of_year.to_date, person_to_keep.member_to, "member_to"
    
    assert_equal "7123811", person_to_keep.license, "license"
    assert_equal 1, person_to_keep.versions.size, "versions"
    assert_equal [ 2 ], person_to_keep.versions.map(&:number).sort, "version numbers"
  end
  
  def test_merge_login
    person_to_keep = FactoryGirl.create(:person)
    person_to_merge = FactoryGirl.create(:person_with_login, :login => "tonkin")

    Timecop.freeze(1.hour.from_now) do
      person_to_merge_old_password = person_to_merge.crypted_password

      assert_equal 0, person_to_merge.versions.size, "versions"
      assert_equal 0, person_to_keep.versions.size, "no versions"
      person_to_keep.merge person_to_merge
      assert_equal 1, person_to_keep.versions.size, "Merge should create only one version"

      person_to_keep.reload
      assert_equal "tonkin", person_to_keep.login, "Should merge login"
      assert_equal person_to_merge_old_password, person_to_keep.crypted_password, "Should merge password"
      changes = person_to_keep.versions.last.changes
      assert_equal [ nil, "tonkin" ], changes["login"], "login change should be recorded"
    end
  end
  
  def test_merge_two_logins
    person_to_keep = FactoryGirl.create(:person, :login => "molly", :password => "secret", :password_confirmation => "secret")
    person_to_keep_old_password = person_to_keep.crypted_password

    person_to_merge = FactoryGirl.create(:person, :login => "tonkin", :password => "secret", :password_confirmation => "secret")
    person_to_merge_old_password = person_to_merge.crypted_password

    person_to_keep.reload
    person_to_merge.reload
    
    person_to_keep.merge person_to_merge
    
    person_to_keep.reload
    assert_equal "molly", person_to_keep.login, "Should preserve login"
    assert_equal person_to_keep_old_password, person_to_keep.crypted_password, "Should preserve password"
  end
  
  def test_merge_no_alias_dup_names
    FactoryGirl.create(:discipline, :name => "Cyclocross")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:number_issuer)

    person_to_keep = FactoryGirl.create(:person, :login => "molly", :password => "secret", :password_confirmation => "secret")
    FactoryGirl.create(:result, :person => person_to_keep)
    FactoryGirl.create(:result, :person => person_to_keep)
    FactoryGirl.create(:result, :person => person_to_keep)
    person_to_keep.aliases.create!(:name => "Mollie Cameron")

    person_to_merge = FactoryGirl.create(:person, :login => "tonkin", :password => "secret", :password_confirmation => "secret")
    FactoryGirl.create(:result, :person => person_to_merge)
    FactoryGirl.create(:result, :person => person_to_merge)
    person_to_merge.aliases.create!(:name => "Eric Tonkin")

    person_same_name_as_merged = Person.create(:name => person_to_merge.name, :road_number => 'YYZ')
    
    assert_not_nil(Person.find_by_first_name_and_last_name(person_to_keep.first_name, person_to_keep.last_name), "#{person_to_keep.name} should be in DB")
    assert_equal(3, Result.find_all_by_person_id(person_to_keep.id).size, "Molly's results")
    assert_equal(1, Alias.find_all_by_person_id(person_to_keep.id).size, "Mollys's aliases")
    
    assert_not_nil(Person.find_by_first_name_and_last_name(person_to_merge.first_name, person_to_merge.last_name), "#{person_to_merge.name} should be in DB")
    assert_equal(2, Result.find_all_by_person_id(person_to_merge.id).size, "Tonkin's results")
    assert_equal(1, Alias.find_all_by_person_id(person_to_merge.id).size, "Tonkin's aliases")
    
    person_to_keep.merge(person_to_merge)
    
    assert_not_nil(Person.find_by_first_name_and_last_name(person_to_keep.first_name, person_to_keep.last_name), "#{person_to_keep.name} should be in DB")
    assert_equal(5, Result.find_all_by_person_id(person_to_keep.id).size, "Molly's results")
    aliases = Alias.find_all_by_person_id(person_to_keep.id)
    erik_alias = aliases.detect{|a| a.name == 'Erik Tonkin'}
    assert_nil(erik_alias, 'Molly should not have Erik Tonkin alias because there is another Erik Tonkin')
    assert_equal(2, Alias.find_all_by_person_id(person_to_keep.id).size, "Molly's aliases")
    
    assert_not_nil(Person.find_by_first_name_and_last_name(person_to_merge.first_name, person_to_merge.last_name), "#{person_to_merge.name} should still be in DB")
    assert_equal(0, Result.find_all_by_person_id(person_to_merge.id).size, "Tonkin's results")
    assert_equal(0, Alias.find_all_by_person_id(person_to_merge.id).size, "Tonkin's aliases")
  end

  def test_name
    person = Person.new(:first_name => 'Dario', :last_name => 'Frederick')
    assert_equal(person.name, 'Dario Frederick', 'name')
    person.name = ''
    assert_equal(person.name, '', 'name')
  end
  
  def test_set_name
    person = Person.new(:first_name => "R. Jim", :last_name => "Smith")
    assert_equal "R. Jim", person.first_name, "first_name"
  end
  
  def test_set_single_name
    person = Person.new(:first_name => "Jim", :last_name => "Smith")
    person.name = "Jim"
    assert_equal "Jim", person.name, "name"
  end
  
  def test_name_or_login
    assert_equal nil, Person.new.name_or_login
    assert_equal "dario@example.com", Person.new(:email => "dario@example.com").name_or_login
    assert_equal "the_dario", Person.new(:login => "the_dario").name_or_login
    assert_equal "Dario", Person.new(:name => "Dario").name_or_login
  end

  def test_member
    person = Person.new(:first_name => 'Dario', :last_name => 'Frederick')
    assert_equal(false, person.member?, 'member')
    assert_nil(person.member_from, 'Member from')
    assert_nil(person.member_to, 'Member to')
    
    person.save!
    person.reload
    assert_equal(false, person.member?, 'member')
    assert_nil(person.member_from, 'Member on')
    assert_nil(person.member_to, 'Member to')

    Timecop.freeze(Time.zone.local(2009, 6)) do
      person.member = true
      assert_equal(true, person.member?, 'member')
      assert_equal_dates(Time.zone.local(2009, 6), person.member_from, 'Member on')
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, 'Member to')
      person.save!
      person.reload
      assert_equal(true, person.member?, 'member')
      assert_equal_dates(Time.zone.local(2009, 6), person.member_from, 'Member on')
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, 'Member to')

      person.member = true
      assert_equal(true, person.member?, 'member')
      assert_equal_dates(Time.zone.local(2009, 6), person.member_from, 'Member on')
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, 'Member to')
      person.save!
    end

    Timecop.freeze(Time.zone.local(2009, 12)) do
      person.reload
      assert_equal(true, person.member?, 'member')
      assert_equal_dates(Time.zone.local(2009, 6), person.member_from, 'Member on')
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, 'Member to')
    end
    
    Timecop.freeze(Time.zone.local(2010)) do
      person.member_from = Time.zone.local(2010)
      person.member_to = Time.zone.local(2010, 12, 31)
      person.member = false
      assert_equal(false, person.member?, 'member')
      assert_nil(person.member_from, 'Member on')
      assert_nil(person.member_to, 'Member to')
      person.save!
      person.reload
      assert_equal(false, person.member?, 'member')
      assert_nil(person.member_from, 'Member on')
      assert_nil(person.member_to, 'Member to')
    end
    
    # From nil, to nil
    Timecop.freeze(Time.zone.local(2009)) do
      person.member_from = nil
      person.member_to = nil
      assert_equal(false, person.member?, 'member?')
      person.member = true
      assert_equal(true, person.member?, 'member')
      assert_equal_dates(Time.zone.local(2009), person.member_from, 'Member from')
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, 'Member to')

      person.member_from = nil
      person.member_to = nil
      assert_equal(false, person.member?, 'member?')
      person.member = false
      person.member_from = nil
      person.member_to = nil
      assert_equal(false, person.member?, 'member?')
    end
    
    # From, to in past
    Timecop.freeze(Time.zone.local(2009, 11)) do
      person.member_from = Time.zone.local(2001, 1, 1)
      person.member_to = Time.zone.local(2001, 12, 31)
      assert_equal(false, person.member?, 'member?')
      assert_equal(false, person.member?(Time.zone.local(2000, 12, 31)), 'member')
      assert_equal(true, person.member?(Time.zone.local(2001, 1, 1)), 'member')
      assert_equal(true, person.member?(Time.zone.local(2001, 12, 31)), 'member')
      assert_equal(false, person.member?(Time.zone.local(2002, 1, 1)), 'member')
      person.member = true
      assert_equal(true, person.member?, 'member')
      assert_equal_dates(Time.zone.local(2001, 1, 1), person.member_from, 'Member from')
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, 'Member to')
    end
    
    Timecop.freeze(Time.zone.local(2009, 12)) do
      person.member_from = Time.zone.local(2001, 1, 1)
      person.member_to = Time.zone.local(2001, 12, 31)
      assert_equal(false, person.member?, 'member?')
      assert_equal(false, person.member?(Time.zone.local(2000, 12, 31)), 'member')
      assert_equal(true, person.member?(Time.zone.local(2001, 1, 1)), 'member')
      assert_equal(true, person.member?(Time.zone.local(2001, 12, 31)), 'member')
      assert_equal(false, person.member?(Time.zone.local(2002, 1, 1)), 'member')
      person.member = true
      assert_equal(true, person.member?, 'member')
      assert_equal_dates(Time.zone.local(2001, 1, 1), person.member_from, 'Member from')
      assert_equal_dates(Time.zone.local(2010, 12, 31), person.member_to, 'Member to')
    end

    person.member_from = Time.zone.local(2001, 1, 1)
    person.member_to = Time.zone.local(2001, 12, 31)
    assert_equal(false, person.member?, 'member?')
    person.member = false
    assert_equal_dates(Time.zone.local(2001, 1, 1), person.member_from, 'Member from')
    person.member_to = Time.zone.local(2001, 12, 31)
    assert_equal(false, person.member?, 'member?')
    
    # From in past, to in future
    Timecop.freeze(Time.zone.local(2009, 1)) do
      person.member_from = Time.zone.local(2001, 1, 1)
      person.member_to = Time.zone.local(3000, 12, 31)
      assert_equal(true, person.member?, 'member?')
      person.member = true
      assert_equal(true, person.member?, 'member')
      assert_equal_dates(Time.zone.local(2001, 1, 1), person.member_from, 'Member from')
      assert_equal_dates(Time.zone.local(3000, 12, 31), person.member_to, 'Member to')

      person.member = false
      assert_equal_dates(Time.zone.local(2001, 1, 1), person.member_from, 'Member from')
      assert_equal_dates(Time.zone.local(2008, 12, 31), person.member_to, 'Member to')
      assert_equal(false, person.member?, 'member?')

      # From, to in future
      person.member_from = Time.zone.local(2500, 1, 1)
      person.member_to = Time.zone.local(3000, 12, 31)
      assert_equal(false, person.member?, 'member?')
      person.member = true
      assert_equal(true, person.member?, 'member')
      assert_equal_dates(Time.zone.local(2009), person.member_from, 'Member from')
      assert_equal_dates('3000-12-31', person.member_to, 'Member to')

      person.member = false
      assert_nil(person.member_from, 'Member on')
      assert_nil(person.member_to, 'Member to')
      assert_equal(false, person.member?, 'member?')
    end
  end
  
  def test_member_in_year
    person = Person.new(:first_name => 'Dario', :last_name => 'Frederick')
    assert_equal(false, person.member_in_year?, 'member_in_year')
    assert_nil(person.member_from, 'Member from')
    assert_nil(person.member_to, 'Member to')

    person.member = true
    assert_equal(true, person.member_in_year?, 'member_in_year')
    person.save!
    person.reload
    assert_equal(true, person.member_in_year?, 'member_in_year')
    
    person.member = false
    assert_equal(false, person.member_in_year?, 'member_in_year')
    person.save!
    person.reload
    assert_equal(false, person.member_in_year?, 'member_in_year')

    # From, to in past
    person.member_from = Date.new(2001, 1, 1)
    person.member_to = Date.new(2001, 12, 31)
    assert_equal(false, person.member_in_year?, 'member_in_year?')
    assert_equal(false, person.member_in_year?(Date.new(2000, 12, 31)), 'member')
    assert_equal(true, person.member_in_year?(Date.new(2001, 1, 1)), 'member')
    assert_equal(true, person.member_in_year?(Date.new(2001, 12, 31)), 'member')
    assert_equal(false, person.member_in_year?(Date.new(2002, 1, 1)), 'member')

    person.member_from = Date.new(2001, 4, 2)
    person.member_to = Date.new(2001, 6, 10)
    assert_equal(false, person.member_in_year?, 'member_in_year?')
    assert_equal(false, person.member_in_year?(Date.new(2000, 12, 31)), 'member')
    assert_equal(true, person.member_in_year?(Date.new(2001, 4, 1)), 'member')
    assert_equal(true, person.member_in_year?(Date.new(2001, 4, 2)), 'member')
    assert_equal(true, person.member_in_year?(Date.new(2001, 6, 10)), 'member')
    assert_equal(true, person.member_in_year?(Date.new(2001, 6, 11)), 'member')
    assert_equal(false, person.member_in_year?(Date.new(2002, 1, 1)), 'member')
  end
  
  def test_member_to
    # from = nil, to = nil
    person = Person.new(:first_name => 'Dario', :last_name => 'Frederick')
    person.member_from = nil
    person.member_to = nil
    assert_equal(false, person.member?, 'member?')
    assert_nil(person.member_from, 'member_from')
    assert_nil(person.member_to, 'member_to')
    
    person.member_to = Date.new(3000, 12, 31)
    assert_equal_dates(Time.zone.today, person.member_from, 'Member from')
    assert_equal_dates('3000-12-31', person.member_to, 'Member to')
    assert_equal(true, person.member?, 'member?')

    # before, before
    person = Person.new(:first_name => 'Dario', :last_name => 'Frederick')
    person.member_from = Date.new(1970, 1, 1)
    person.member_to = Date.new(1970, 12, 31)

    person.member_to = Date.new(1971, 7, 31)
    assert_equal_dates(Date.new(1970, 1, 1), person.member_from, 'Member from')
    assert_equal_dates('1971-07-31', person.member_to, 'Member to')
    assert_equal(false, person.member?, 'member?')

    # before, after
    person = Person.new(:first_name => 'Dario', :last_name => 'Frederick')
    person.member_from = Date.new(1970, 1, 1)
    person.member_to = Date.new(1985, 12, 31)

    person.member_to = Date.new(1971, 7, 31)
    assert_equal_dates(Date.new(1970, 1, 1), person.member_from, 'Member from')
    assert_equal_dates('1971-07-31', person.member_to, 'Member to')
    assert_equal(false, person.member?, 'member?')

    # after, after
    person = Person.new(:first_name => 'Dario', :last_name => 'Frederick')
    person.member_from = Date.new(2006, 1, 1)
    person.member_to = Date.new(2006, 12, 31)

    person.member_to = Date.new(2000, 1, 31)
    assert_equal_dates(Date.new(2000, 1, 31), person.member_from, 'Member from')
    assert_equal_dates('2000-01-31', person.member_to, 'Member to')
    assert_equal(false, person.member?, 'member?')
  end
  
  def test_team_name
    person = Person.new(:first_name => 'Dario', :last_name => 'Frederick')
    assert_equal(person.team_name, '', 'name')

    person.team_name = 'Vanilla'
    assert_equal('Vanilla', person.team_name, 'name')

    person.team_name = 'Pegasus'
    assert_equal('Pegasus', person.team_name, 'name')

    person.team_name = ''
    assert_equal('', person.team_name, 'name')
  end
  
  def test_duplicate
    FactoryGirl.create(:discipline, :name => "Cyclocross")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:number_issuer)
    
    Person.create(:first_name => 'Otis', :last_name => 'Guy')
    person = Person.new(:first_name => 'Otis', :last_name => 'Guy')
    assert(person.valid?, 'Dupe person name with no number should be valid')

    person = Person.new(:first_name => 'Otis', :last_name => 'Guy', :road_number => '180')
    assert(person.valid?, 'Dupe person name valid even if person has no numbers')

    Person.create(:first_name => 'Otis', :last_name => 'Guy', :ccx_number => '180')
    Person.create(:first_name => 'Otis', :last_name => 'Guy', :ccx_number => '19')
  end
  
  def test_master?
    person = Person.new
    assert(!person.master?, 'Master?')
    
    person.date_of_birth = Date.new((RacingAssociation.current.masters_age - 1).years.ago.year, 1, 1)
    assert(!person.master?, 'Master?')

    person.date_of_birth = Date.new(RacingAssociation.current.masters_age.years.ago.year, 12, 31)
    assert(person.master?, 'Master?')
    
    person.date_of_birth = Date.new(17.years.ago.year, 1, 1)
    assert(!person.master?, 'Master?')

    # Greater then 36 or so years in the past will give an ArgumentError on Windows
    person.date_of_birth = Date.new((RacingAssociation.current.masters_age + 1).years.ago.year, 12, 31)
    assert(person.master?, 'Master?')
  end
  
  def test_junior?
    person = Person.new
    assert(!person.junior?, 'Junior?')
    
    person.date_of_birth = Date.new(19.years.ago.year, 1, 1)
    assert(!person.junior?, 'Junior?')

    person.date_of_birth = Date.new(18.years.ago.year, 12, 31)
    assert(person.junior?, 'Junior?')
    
    person.date_of_birth = Date.new(21.years.ago.year, 1, 1)
    assert(!person.junior?, 'Junior?')

    person.date_of_birth = Date.new(12.years.ago.year, 12, 31)
    assert(person.junior?, 'Junior?')
  end
  
  def test_racing_age
    person = Person.new
    assert_nil(person.racing_age)

    person.date_of_birth = 29.years.ago
    assert_equal(29, person.racing_age, 'racing_age')

    person.date_of_birth = Date.new(29.years.ago.year, 1, 1)
    assert_equal(29, person.racing_age, 'racing_age')

    person.date_of_birth = Date.new(29.years.ago.year, 12, 31)
    assert_equal(29, person.racing_age, 'racing_age')

    person.date_of_birth = Date.new(30.years.ago.year, 12, 31)
    assert_equal(30, person.racing_age, 'racing_age')

    person.date_of_birth = Date.new(28.years.ago.year, 1, 1)
    assert_equal(28, person.racing_age, 'racing_age')
  end
  
  def test_cyclocross_racing_age
    person = Person.new
    assert_nil(person.cyclocross_racing_age)

    person.date_of_birth = 29.years.ago
    assert_equal(30, person.cyclocross_racing_age, "cyclocross_racing_age")

    person.date_of_birth = Date.new(29.years.ago.year, 1, 1)
    assert_equal(30, person.cyclocross_racing_age, "cyclocross_racing_age")

    person.date_of_birth = Date.new(29.years.ago.year, 12, 31)
    assert_equal(30, person.cyclocross_racing_age, "cyclocross_racing_age")

    person.date_of_birth = Date.new(30.years.ago.year, 12, 31)
    assert_equal(31, person.cyclocross_racing_age, "cyclocross_racing_age")

    person.date_of_birth = Date.new(28.years.ago.year, 1, 1)
    assert_equal(29, person.cyclocross_racing_age, "cyclocross_racing_age")
  end
  
  def test_bmx_category
    person = FactoryGirl.create(:person)
    assert_nil(person.bmx_category, "BMX category")
    person.bmx_category = "H100"
    assert_equal("H100", person.bmx_category, "BMX category")
  end
  
  def test_blank_numbers
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, :name => "Cyclocross")
    FactoryGirl.create(:discipline, :name => "Downhill")
    FactoryGirl.create(:discipline, :name => "Road")    
    FactoryGirl.create(:discipline, :name => "Time Trial")
    FactoryGirl.create(:discipline, :name => "Track")

    person = Person.new
    assert_nil(person.ccx_number, 'cross number after new')
    assert_nil(person.dh_number, 'dh number after new')
    assert_nil(person.road_number, 'road number after new')
    assert_nil(person.track_number, 'track number after new')
    assert_nil(person.xc_number, 'xc number after new')
    
    person.save!
    person.reload
    assert_nil(person.ccx_number, 'cross number after save')
    assert_nil(person.dh_number, 'dh number after save')
    assert_nil(person.road_number, 'road number after save')
    assert_nil(person.track_number, 'track number after save')
    assert_nil(person.xc_number, 'xc number after save')
    
    person = Person.update(
      person.id, 
      :ccx_number => '',
      :dh_number => '',
      :road_number => '',
      :track_number => '',
      :xc_number => ''
    )
    assert_nil(person.ccx_number, 'cross number after update with empty string')
    assert_nil(person.dh_number, 'dh number after update with empty string')
    assert_nil(person.road_number, 'road number after update with empty string')
    assert_nil(person.track_number, 'track number after update with empty string')
    assert_nil(person.xc_number, 'xc number after update with empty string')
   
    person.reload
    assert_nil(person.ccx_number, 'cross number after update with empty string')
    assert_nil(person.dh_number, 'dh number after update with empty string')
    assert_nil(person.road_number, 'road number after update with empty string')
    assert_nil(person.track_number, 'track number after update with empty string')
    assert_nil(person.xc_number, 'xc number after update with empty string')
  end
  
  def test_numbers
    FactoryGirl.create(:number_issuer)
    cyclocross = FactoryGirl.create(:discipline, :name => "Cyclocross")
    FactoryGirl.create(:discipline_alias, :discipline => cyclocross, :alias => "cx")
    FactoryGirl.create(:discipline_alias, :discipline => cyclocross, :alias => "ccx")
    FactoryGirl.create(:discipline, :name => "Road")    
    FactoryGirl.create(:discipline, :name => "Time Trial")
    
    tonkin = FactoryGirl.create(:person, :road_number => "102")
    tonkin.ccx_number = "U89"
    assert_equal("U89", tonkin.ccx_number)
    assert_equal("U89", tonkin.number(:ccx))
    assert_equal("U89", tonkin.number("ccx"))
    assert_equal("U89", tonkin.number("Cyclocross"))
    assert_equal("U89", tonkin.number(Discipline["Cyclocross"]))
    assert_equal "102", tonkin.number("Time Trial")
  end
  
  def test_date
    person = Person.new(:date_of_birth => '0073-10-04')
    assert_equal_dates('1973-10-04', person.date_of_birth, 'date_of_birth from 0073-10-04')

    person = Person.new(:date_of_birth => "10/27/78")
    assert_equal_dates('1978-10-27', person.date_of_birth, 'date_of_birth from 10/27/78')

    person = Person.new(:date_of_birth => "78")
    assert_equal_dates('1978-01-01', person.date_of_birth, 'date_of_birth from 78')
  end
  
  def test_date_of_birth
    person = Person.new(:date_of_birth => '1973-10-04')
    assert_equal_dates('1973-10-04', person.date_of_birth, 'date_of_birth from 1973-10-04')
    assert_equal_dates('1973-10-04', person.birthdate, 'birthdate from 173-10-04')

    person = Person.new(:date_of_birth => "05/07/73")
    assert_equal_dates "1973-05-07", person.date_of_birth, "date_of_birth from 05/07/73"
  end
  
  def test_find_by_number
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, :name => "Road")
    person = FactoryGirl.create(:person, :road_number => "340")
    found_person = Person.find_by_number('340')
    assert_equal([person], found_person, 'Should find Matson')
  end
  
  def test_find_all_by_name_like
    assert_equal([], Person.find_all_by_name_like("foo123"), "foo123 should find no names")
    weaver = FactoryGirl.create(:person, :name => "Ryan Weaver")
    assert_equal([weaver], Person.find_all_by_name_like("eav"), "'eav' should find Weaver")

    weaver.last_name = "O'Weaver"
    weaver.save!
    assert_equal([weaver], Person.find_all_by_name_like("eav"), "'eav' should find O'Weaver")
    assert_equal([weaver], Person.find_all_by_name_like("O'Weaver"), "'O'Weaver' should find O'Weaver")

    weaver.last_name = "Weaver"
    weaver.save!
    Alias.create!(:name => "O'Weaver", :person => weaver)
    assert_equal([weaver], Person.find_all_by_name_like("O'Weaver"), "'O'Weaver' should find O'Weaver via alias")
  end
  
  def test_find_by_name
    weaver = FactoryGirl.create(:person, :name => "Ryan Weaver")
    assert_equal weaver, Person.find_by_name("Ryan Weaver"), "find_by_name"
    
    person = Person.create!(:first_name => "Sam")
    assert_equal person, Person.find_by_name("Sam"), "find_by_name first_name only"
    
    person = Person.create!(:last_name => "Richardson")
    assert_equal person, Person.find_by_name("Richardson"), "find_by_name last_name only"
  end
  
  def test_hometown
    person = Person.new
    assert_equal('', person.hometown, 'New Person hometown')
    
    person.city = 'Newport'
    assert_equal('Newport', person.hometown, 'Person hometown')
    
    person.city = nil
    person.state = RacingAssociation.current.state
    assert_equal('', person.hometown, 'Person hometown')
    
    person.city = 'Fossil'
    person.state = RacingAssociation.current.state
    assert_equal('Fossil', person.hometown, 'Person hometown')
    
    person.city = nil
    person.state = 'NY'
    assert_equal('NY', person.hometown, 'Person hometown')
    
    person.city = 'Petaluma'
    person.state = 'CA'
    assert_equal('Petaluma, CA', person.hometown, 'Person hometown')
    
    person = Person.new
    assert_equal(nil, person.city, 'New Person city')
    assert_equal(nil, person.state, 'New Person state')
    person.hometown = ''
    assert_equal(nil, person.city, 'New Person city')
    assert_equal(nil, person.state, 'New Person state')
    person.hometown = nil
    assert_equal(nil, person.city, 'New Person city')
    assert_equal(nil, person.state, 'New Person state')
    
    person.hometown = 'Newport'
    assert_equal('Newport', person.city, 'New Person city')
    assert_equal(nil, person.state, 'New Person state')
    
    person.hometown = 'Newport, RI'
    assert_equal('Newport', person.city, 'New Person city')
    assert_equal('RI', person.state, 'New Person state')
    
    person.hometown = nil
    assert_equal(nil, person.city, 'New Person city')
    assert_equal(nil, person.state, 'New Person state')
    
    person.hometown = ''
    assert_equal(nil, person.city, 'New Person city')
    assert_equal(nil, person.state, 'New Person state')
    
    person.hometown = 'Newport, RI'
    person.hometown = ''
    assert_equal(nil, person.city, 'New Person city')
    assert_equal(nil, person.state, 'New Person state')
  end

  def test_create_and_override_alias
    person = FactoryGirl.create(:person, :name => "Molly Cameron")
    person.aliases.create!(:name => "Mollie Cameron")
    
    assert_not_nil(Person.find_by_name('Molly Cameron'), 'Molly Cameron should exist')
    assert_not_nil(Alias.find_by_name('Mollie Cameron'), 'Mollie Cameron alias should exist')
    assert_nil(Person.find_by_name('Mollie Cameron'), 'Mollie Cameron should not exist')

    dupe = Person.create!(:name => 'Mollie Cameron')
    assert(dupe.valid?, 'Dupe Mollie Cameron should be valid')
    
    assert_not_nil(Person.find_by_name('Molly Cameron'), 'Molly Cameron should exist')
    assert_not_nil(Person.find_by_name('Mollie Cameron'), 'Ryan Weaver should exist')
    assert_nil(Alias.find_by_name('Molly Cameron'), 'Molly Cameron alias should not exist')
    assert_nil(Alias.find_by_name('Mollie Cameron'), 'Mollie Cameron alias should not exist')
  end
  
  def test_update_to_alias
    person = FactoryGirl.create(:person, :name => "Molly Cameron")
    person.aliases.create!(:name => "Mollie Cameron")
    
    # Reload to set old name correctly
    person = Person.find(person.id)

    person.name = 'Mollie Cameron'
    person.save!
    assert(person.valid?, 'Renamed Mollie Cameron should be valid')
    
    assert_not_nil(Person.find_by_name('Mollie Cameron'), 'Mollie Cameron should exist')
    assert_nil(Person.find_by_name('Molly Cameron'), 'Molly Cameron should not exist')
    assert_nil(Alias.find_by_name('Mollie Cameron'), 'Mollie Cameron alias should not exist')
    assert_not_nil(Alias.find_by_name('Molly Cameron'), 'Molly Cameron alias should exist')
  end
  
  def test_sort
    r1 = Person.new(:name => "Aarron Burr")
    r1.id = 1
    r2 = Person.new(:name => "Aarron Car")
    r2.id = 2
    r3 = Person.new(:name => "A Lincoln")
    r3.id = 3
    
    people = [r2, r1, r3]
    people.sort!
    
    assert_equal([r1, r2, r3], people, 'sorted')
  end
  
  def test_add_number
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:number_issuer)
    
    person = Person.create!
    person.add_number("7890", nil)
    assert_equal("7890", person.road_number, "Road number after add with nil discipline")    
  end
  
  def test_add_number_from_non_number_discipline
    FactoryGirl.create(:discipline, :name => "Circuit", :numbers => false)
    road = FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:number_issuer)

    person = Person.create!
    circuit_race = Discipline[:circuit]
    person.add_number("7890", circuit_race)
    assert_equal("7890", person.road_number, "Road number")
    assert_equal("7890", person.number(circuit_race), "Circuit race number")
  end
  
  # Legacy test … used to look at data to devine creator
  def test_created_from_result?
    person = Person.create!
    assert(!person.created_from_result?, "created_from_result? for blank Person")

    person = Person.create!(:name => "Some Person")
    assert(!person.created_from_result?, "created_from_result? for Person with just name")

    gentle_lovers = FactoryGirl.create(:team)
    person = Person.create!(:name => "Some Person", :team => gentle_lovers)
    assert(!person.created_from_result?, "created_from_result? for Person with just name and team")

    person = Person.create!(:name => "Some Person", :team => gentle_lovers, :email => "person@example.com")
    assert(!person.created_from_result?, "created_from_result? for Person with name and team and email")

    person = Person.create!(:name => "Some Person", :team => gentle_lovers, :home_phone => "911")
    assert(!person.created_from_result?, "created_from_result? for Person with name and team and phone")

    person = Person.create!(:name => "Some Person", :team => gentle_lovers, :street => "10 Main Street")
    assert(!person.created_from_result?, "created_from_result? for Person with name and team and street")
  end
  
  def test_people_with_same_name
    molly = FactoryGirl.create(:person, :name => "Molly Cameron")
    molly.aliases.create!(:name => "Mollie Cameron")

    assert_equal([], molly.people_with_same_name, "No other people named 'Molly Cameron'")

    person = FactoryGirl.create(:person, :name => "Mollie Cameron")
    assert_equal([], molly.people_with_same_name, "No other people named 'Mollie Cameron'")

    Person.create!(:name => "Mollie Cameron")
    assert_equal(1, person.people_with_same_name.size, "Other people named 'Mollie Cameron'")
  end
  
  def test_dh_number_with_no_downhill_discipline
    downhill = FactoryGirl.create(:discipline, :name => "Downhill")
    downhill.destroy
    Discipline.reset
   
    assert(!Discipline.exists?(:name => "Downhill"), "Downhill should be deleted")
    person = FactoryGirl.create(:person)
    assert_nil(person.dh_number, "DH number")
  end
  
  def test_find_all_by_name_or_alias
    tonkin = FactoryGirl.create(:person, :name => "Erik Tonkin")
    tonkin.aliases.create!(:name => "Eric Tonkin")
    new_tonkin = Person.create!(:name => "Erik Tonkin")
    assert_equal(2, Person.find_all_by_name("Erik Tonkin").size, "Should have 2 Tonkins")
    assert_equal(2, Person.find_all_by_name_or_alias(:first_name => "Erik", :last_name => "Tonkin").size, "Should have 2 Tonkins")
    assert_raise(ArgumentError) { Person.find_all_by_name("Erik", "Tonkin") }
  end
  
  def test_find_all_for_export
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, :name => "Cyclocross")
    FactoryGirl.create(:discipline, :name => "Downhill")
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")    
    FactoryGirl.create(:discipline, :name => "Singlespeed")
    FactoryGirl.create(:discipline, :name => "Time Trial")
    FactoryGirl.create(:discipline, :name => "Track")
    
    FactoryGirl.create(:person, :name => "Molly Cameron")
    kona = FactoryGirl.create(:team, :name => "Kona")
    FactoryGirl.create(
      :person, 
      :name => "Erik Tonkin", 
      :team => kona, 
      :track_category => "4"
    )
    FactoryGirl.create(:person, :name => "Mark Matson", :team => kona)
    FactoryGirl.create(
      :person, 
      :name => "Alice Pennington",
      :date_of_birth => 30.years.ago, 
      :member_from => Date.new(1996), 
      :member_to => Time.zone.now.end_of_year.to_date,
      :track_category => "5"
    )
    FactoryGirl.create(:person, :name => "Candi Murray")
    FactoryGirl.create(:person)
    FactoryGirl.create(:person, :name => "Kevin Condron")

    people = Person.find_all_for_export
    assert_equal("Molly", people[0]["first_name"], "Row 0 first_name")
    assert_equal("Kona", people[2]["team_name"], "Row 2 team: #{people[2]}")
    assert_equal(30, people[4]["racing_age"], "Row 4 racing_age #{people[4]}")
    assert_equal("01/01/1996", people[4]["member_from"], "Row 4 member_from")
    assert_equal("12/31/#{Time.zone.today.year}", people[4]["member_to"], "Row 4 member_to")
    assert_equal("5", people[4]["track_category"], "Row 4 track_category")
  end

  def test_find_or_create_by_name
    tonkin = FactoryGirl.create(:person, :name => "Erik Tonkin")
    person = Person.find_or_create_by_name("Erik Tonkin")
    assert_equal tonkin, person, "Should find existing person"

    person = Person.find_or_create_by_name("Sam Richardson")
    assert_equal "Sam Richardson", person.name, "New person name"
    assert_equal "Sam", person.first_name, "New person first_name"
    assert_equal "Richardson", person.last_name, "New person last_name"
    person_2 = Person.find_or_create_by_name("Sam Richardson")
    assert_equal person, person_2, "Should find new person"

    person = Person.find_or_create_by_name("Sam")
    assert_equal "Sam", person.name, "New person name"
    assert_equal "Sam", person.first_name, "New person first_name"
    assert_equal "", person.last_name, "New person last_name"
    person_2 = Person.find_or_create_by_name("Sam")
    assert_equal person, person_2, "Should find new person"
  end
  
  def test_create
    Person.create!(:name => 'Mr. Tuxedo', :password =>'blackcat', :password_confirmation =>'blackcat', :email => "tuxedo@example.com")
  end
  
  def test_find_by_info
    promoter = FactoryGirl.create(:promoter, :name => "Brad Ross")
    assert_equal(promoter, Person.find_by_info("Brad ross"))
    assert_equal(promoter, Person.find_by_info("Brad ross", "brad@foo.com"))
    
    administrator = FactoryGirl.create(:administrator)
    assert_equal(administrator, Person.find_by_info("Candi Murray"))
    assert_equal(administrator, Person.find_by_info("Candi Murray", "admin@example.com", "(503) 555-1212"))
    assert_equal(administrator, Person.find_by_info("", "admin@example.com", "(503) 555-1212"))
    assert_equal(administrator, Person.find_by_info("", "admin@example.com"))

    assert_nil(Person.find_by_info("", "mike_murray@obra.org", "(451) 324-8133"))
    assert_nil(Person.find_by_info("", "membership@obra.org"))
    
    promoter = Person.new(:name => '', :home_phone => "(212) 522-1872")
    promoter.save!
    assert_equal(promoter, Person.find_by_info("", "", "(212) 522-1872"))
    
    promoter = Person.new(:name => '', :email => "cjw@cjw.net")
    promoter.save!
    assert_equal(promoter, Person.find_by_info("", "cjw@cjw.net", ""))
  end
  
  def test_save_blank
    assert Person.new.valid?
  end
  
  def test_save_no_name
    Person.create!(:email => "nate@six-hobsons.net")
    assert(Person.new(:email => "nate@six-hobsons.net").valid?, "Dupe email addresses allowed")
  end
  
  def test_save_no_email
    assert Person.new(:name => "Nate Hobson").valid?
  end
  
  def test_administrator
    administrator = FactoryGirl.create(:administrator)
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person)
    
    assert(administrator.administrator?, 'administrator administrator?')
    assert(!promoter.administrator?, 'promoter administrator?')
    assert(!member.administrator?, 'administrator administrator?')
  end
  
  def test_promoter
    administrator = FactoryGirl.create(:administrator)
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person)

    assert !administrator.promoter?, "administrator promoter?"
    assert promoter.promoter?, "promoter promoter?"
    assert !member.promoter?, "person promoter?"
  end
  
  def test_login_with_periods
    Person.create!(:name => 'Mr. Tuxedo', :password =>'blackcat', :password_confirmation =>'blackcat', :login => "tuxedo.cat@example.com")
  end
  
  def test_long_login
    person = Person.create!(
      :name => 'Mr. Tuxedo', 
      :password =>'blackcatthebestkittyinblacktuxatonypa', 
      :password_confirmation =>'blackcatthebestkittyinblacktuxatonypa', 
      :login => "tuxedo.black.cat@subdomain123456789.example.com"
    )
    person.reload
    assert_equal "tuxedo.black.cat@subdomain123456789.example.com", person.login, "login"
    assert PersonSession.create!(
    :login => "tuxedo.black.cat@subdomain123456789.example.com",
    :password =>'blackcatthebestkittyinblacktuxatonypa'
    )
  end
  
  def test_ignore_blank_login_fields
    Person.create!
    person = Person.create!(:password => "", :password_confirmation => "", :login => "")
    person.reload
    person.save!
    person.name = "New Guy"
    person.save!
    
    assert_equal "", person.login, "Login should be blank"
    another = Person.create!(:login => "")
    another.reload
    assert_equal "", another.login, "Login should be blank"
    
    person.login = "samiam@example.com"
    person.password = "secret"
    person.password_confirmation = "secret"
    person.save!
    
    another.login = "samiam@example.com"
    another.password = "secret"
    another.password_confirmation = "secret"
    assert_equal false, another.save, "Should not allow dupe login"
    assert another.errors[:login], "Should have error on login"
  end
  
  def test_authlogic_should_not_set_updated_at_on_load
    person = Person.create!(:name => "Joe Racer", :updated_at => '2008-10-01')
    assert_equal_dates "2008-10-01", person.updated_at, "updated_at"
    person = Person.find(person.id)
    assert_equal_dates "2008-10-01", person.updated_at, "updated_at"
  end
  
  def test_destroy_with_editors
    person = Person.create!
    alice = FactoryGirl.create(:person)
    person.editors << alice
    assert alice.editable_people.any?, "should be editor"
    person.destroy
    assert !Person.exists?(person)
    assert alice.editable_people(true).empty?, "should remove editors"
  end

  def test_multiple_names
    person = FactoryGirl.create(:person, :name => "Ryan Weaver")

    person.names.create!(:first_name => "R", :last_name => "Weavedog", :name => "R Weavedog", :year => 2001)
    person.names.create!(:first_name => "Mister", :last_name => "Weavedog", :name => "Mister Weavedog", :year => 2002)
    person.names.create!(:first_name => "Ryan", :last_name => "Farris", :name => "Ryan Farris", :year => 2003)

    assert_equal(3, person.names.size, "Historical names. #{person.names.map {|n| n.name}.join(', ')}")

    assert_equal("R Weavedog", person.name(2000), "Historical name 2000")
    assert_equal("R", person.first_name(2000), "Historical first_name 2000")
    assert_equal("Weavedog", person.last_name(2000), "Historical last_name 2000")

    assert_equal("R Weavedog", person.name(2001), "Historical name 2001")
    assert_equal("R", person.first_name(2001), "Historical first_name 2001")
    assert_equal("Weavedog", person.last_name(2001), "Historical last_name 2001")

    assert_equal("Mister Weavedog", person.name(2002), "Historical name 2002")
    assert_equal("Mister", person.first_name(2002), "Historical first_name 2002")
    assert_equal("Weavedog", person.last_name(2002), "Historical last_name 2002")

    assert_equal("Ryan Farris", person.name(2003), "Historical name 2003")
    assert_equal("Ryan Farris", person.name(2004), "Historical name 2004")
    assert_equal("Ryan Farris", person.name(Time.zone.today.year - 1), "Historical name last year")
    assert_equal("Ryan Weaver", person.name(Time.zone.today.year), "Name this year")
    assert_equal("Ryan Weaver", person.name(Time.zone.today.year + 1), "Name next year")
  end
  
  def test_create_new_name_if_there_are_results_from_previous_year
    person = FactoryGirl.create(:person, :name => "Ryan Weaver")
    person = Person.find(person.id)
    event = SingleDayEvent.create!(:date => 1.year.ago)
    senior_men = FactoryGirl.create(:category)
    old_result = event.races.create!(:category => senior_men).results.create!(:person => person)
    assert_equal("Ryan Weaver", old_result.name, "Name on old result")
    assert_equal("Ryan", old_result.first_name, "first_name on old result")
    assert_equal("Weaver", old_result.last_name, "last_name on old result")
    
    event = SingleDayEvent.create!(:date => Time.zone.today)
    result = event.races.create!(:category => senior_men).results.create!(:person => person)
    assert_equal("Ryan Weaver", old_result.name, "Name on old result")
    assert_equal("Ryan", old_result.first_name, "first_name on old result")
    assert_equal("Weaver", old_result.last_name, "last_name on old result")
    
    person.name = "Rob Farris"
    person.save!

    assert_equal(1, person.names(true).size, "names")

    assert_equal("Ryan Weaver", old_result.reload.name, "name should stay the same on old result")
    assert_equal("Ryan", old_result.reload.first_name, "first_name on old result")
    assert_equal("Weaver", old_result.reload.last_name, "last_name on old result")

    assert_equal("Rob Farris", result.reload.name, "name should change on this year's result")
    assert_equal("Rob", result.reload.first_name, "first_name on result")
    assert_equal("Farris", result.reload.last_name, "last_name on result")
  end

  def test_renewed
    person = Person.create!
    assert !person.renewed?, "New person"

    Timecop.freeze(Date.new(2009, 11, 30)) do
      person = Person.create!(:member_from => Date.new(2009, 1, 1), :member_to => Date.new(2009, 12, 31))
      assert person.renewed?, "Before Dec 1"
    end

    person = Person.create!(:member_from => Date.new(2009, 1, 1), :member_to => Date.new(2009, 12, 31))
    Timecop.freeze(Time.zone.local(2009, 12, 1)) do
      assert !person.renewed?, "On Dec 1"
    end

    Timecop.freeze(Date.new(2010, 1, 1)) do
      assert !person.renewed?, "Next year"
    end
  end
  
  def test_can_edit
    p1 = Person.create!
    p2 = Person.create!
    admin = FactoryGirl.create(:administrator)
    
    assert !p1.can_edit?(p2)
    assert !p1.can_edit?(admin)
    assert p1.can_edit?(p1)
    assert !p2.can_edit?(p1)
    assert !p2.can_edit?(admin)
    assert p2.can_edit?(p2)
    assert admin.can_edit?(p1)
    assert admin.can_edit?(p2)
    assert admin.can_edit?(admin)

    p1.editors << p2
    assert !p1.can_edit?(p2)
    assert !p1.can_edit?(admin)
    assert p1.can_edit?(p1)
    assert p2.can_edit?(p1)
    assert !p2.can_edit?(admin)
    assert p2.can_edit?(p2)
    assert admin.can_edit?(p1)
    assert admin.can_edit?(p2)
    assert admin.can_edit?(admin)

    p2.editors << p1
    assert p1.can_edit?(p2)
    assert !p1.can_edit?(admin)
    assert p1.can_edit?(p1)
    assert p2.can_edit?(p1)
    assert !p2.can_edit?(admin)
    assert p2.can_edit?(p2)
    assert admin.can_edit?(p1)
    assert admin.can_edit?(p2)
    assert admin.can_edit?(admin)

    admin.editors << p1
    assert p1.can_edit?(p2)
    assert p1.can_edit?(admin)
    assert p1.can_edit?(p1)
    assert p2.can_edit?(p1)
    assert !p2.can_edit?(admin)
    assert p2.can_edit?(p2)
    assert admin.can_edit?(p1)
    assert admin.can_edit?(p2)
    assert admin.can_edit?(admin)
  end

  def assert_renew(now, member_from, member_to, expected_member_from, expected_member_to)
    now = now.to_date
    person = Person.new
    person.renew(now)
    assert_equal true, person.member?(now), "member? for #{now.to_formatted_s(:db)}. Member: #{member_from.to_formatted_s(:db) if member_from}- #{member_to.to_formatted_s(:db) if member_to}"
    assert_equal_dates expected_member_from, person.member_from, "member_from for #{now.to_formatted_s(:db)}. Member: #{member_from.to_formatted_s(:db) if member_from}- #{member_to.to_formatted_s(:db) if member_to}"
    assert_equal_dates expected_member_to, person.member_to, "member_to for #{now.to_formatted_s(:db)}. Member: #{member_from.to_formatted_s(:db) if member_from}- #{member_to.to_formatted_s(:db) if member_to}"
  end
end
