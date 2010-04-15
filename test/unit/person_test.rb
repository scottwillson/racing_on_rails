require "test_helper"

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
    result = event.races.create!(:category => categories(:senior_men)).results.create!(:team => team)
    team.aliases.create!(:name => "Sorella Forte")
    assert_equal(0, team.historical_names(true).size, "historical_names")
    assert_equal(1, team.aliases(true).size, "Aliases")
    assert_equal(["Sorella Forte"], team.aliases.map(&:name).sort, "Team aliases")
    
    person = Person.new(:name => "New Person", :team_name => "Sorella Forte")
    person.save!

    assert_equal(1, Team.count(:conditions => { :name => "Sorella Forte Elite Team"} ), "Should have one Sorella Forte in database")
    team = Team.find_by_name("Sorella Forte Elite Team")
    assert_equal(0, team.historical_names(true).size, "historical_names")
    assert_equal(1, team.aliases(true).size, "Aliases")
    assert_equal(["Sorella Forte"], team.aliases.map(&:name).sort, "Team aliases")
  end

  def test_merge
    person_to_keep = people(:molly)
    person_to_merge = people(:tonkin)
    
    person_to_keep.login = "molly"
    person_to_keep.password = "secret"
    person_to_keep.password_confirmation = "secret"
    person_to_keep.save!
    person_to_keep_old_password = person_to_keep.crypted_password
    
    assert_not_nil(Person.find_by_first_name_and_last_name(person_to_keep.first_name, person_to_keep.last_name), "#{person_to_keep.name} should be in DB")
    assert_equal(3, Result.find_all_by_person_id(person_to_keep.id).size, "Molly's results")
    assert_equal(1, Alias.find_all_by_person_id(person_to_keep.id).size, "Mollys's aliases")
    assert_equal(1, person_to_keep.race_numbers.count, "Target person's race numbers")
    assert_equal("202", person_to_keep.race_numbers.first.value, "Target person's race number value")
    association = NumberIssuer.find_by_name(ASSOCIATION.short_name)
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
    erik_alias = aliases.detect{|a| a.name == 'Erik Tonkin'}
    assert_not_nil(erik_alias, 'Molly should have Erik Tonkin alias')
    assert_equal(3, Alias.find_all_by_person_id(person_to_keep.id).size, "Molly's aliases")
    assert_equal(3, person_to_keep.race_numbers.count, "Target person's race numbers")
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
  end
  
  def test_merge_login
    person_to_keep = people(:molly)
    person_to_merge = people(:tonkin)
    
    person_to_merge.login = "tonkin"
    person_to_merge.password = "secret"
    person_to_merge.password_confirmation = "secret"
    person_to_merge.save!
    person_to_merge_old_password = person_to_merge.crypted_password

    person_to_keep.merge person_to_merge
    
    person_to_keep.reload
    assert_equal "tonkin", person_to_keep.login, "Should merge login"
    assert_equal person_to_merge_old_password, person_to_keep.crypted_password, "Should merge password"
  end
  
  def test_merge_two_logins
    person_to_keep = people(:molly)
    person_to_merge = people(:tonkin)
    
    person_to_keep.login = "molly"
    person_to_keep.password = "secret"
    person_to_keep.password_confirmation = "secret"
    person_to_keep.save!
    person_to_keep_old_password = person_to_keep.crypted_password

    person_to_merge.login = "tonkin"
    person_to_merge.password = "secret"
    person_to_merge.password_confirmation = "secret"
    person_to_merge.save!
    person_to_merge_old_password = person_to_merge.crypted_password

    person_to_keep.reload
    person_to_merge.reload
    
    person_to_keep.merge person_to_merge
    
    person_to_keep.reload
    assert_equal "molly", person_to_keep.login, "Should preserve login"
    assert_equal person_to_keep_old_password, person_to_keep.crypted_password, "Should preserve password"
  end
  
  def test_merge_no_alias_dup_names
    person_to_keep = people(:molly)
    person_to_merge = people(:tonkin)
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

    ASSOCIATION.now = Date.new(2009, 6)
    person.member = true
    assert_equal(true, person.member?, 'member')
    assert_equal(Date.new(2009, 6), person.member_from, 'Member on')
    assert_equal(Date.new(2009, 12, 31), person.member_to, 'Member to')
    person.save!
    person.reload
    assert_equal(true, person.member?, 'member')
    assert_equal(Date.new(2009, 6), person.member_from, 'Member on')
    assert_equal(Date.new(2009, 12, 31), person.member_to, 'Member to')

    ASSOCIATION.now = Date.new(2009, 12)
    person.member = true
    assert_equal(true, person.member?, 'member')
    assert_equal(Date.new(2009, 6), person.member_from, 'Member on')
    assert_equal(Date.new(2010, 12, 31), person.member_to, 'Member to')
    person.save!
    person.reload
    assert_equal(true, person.member?, 'member')
    assert_equal(Date.new(2009, 6), person.member_from, 'Member on')
    assert_equal(Date.new(2010, 12, 31), person.member_to, 'Member to')
    
    ASSOCIATION.now = Date.new(2010)
    person.member_from = Date.new(2010)
    person.member_to = Date.new(2010, 12, 31)
    person.member = false
    assert_equal(false, person.member?, 'member')
    assert_nil(person.member_from, 'Member on')
    assert_nil(person.member_to, 'Member to')
    person.save!
    person.reload
    assert_equal(false, person.member?, 'member')
    assert_nil(person.member_from, 'Member on')
    assert_nil(person.member_to, 'Member to')
    
    # From nil, to nil
    ASSOCIATION.now = Date.new(2009)
    person.member_from = nil
    person.member_to = nil
    assert_equal(false, person.member?, 'member?')
    person.member = true
    assert_equal(true, person.member?, 'member')
    assert_equal(Date.new(2009), person.member_from, 'Member from')
    assert_equal(Date.new(2009, 12, 31), person.member_to, 'Member to')
    
    person.member_from = nil
    person.member_to = nil
    assert_equal(false, person.member?, 'member?')
    person.member = false
    person.member_from = nil
    person.member_to = nil
    assert_equal(false, person.member?, 'member?')
    
    # From, to in past
    ASSOCIATION.now = Date.new(2009, 11)
    person.member_from = Date.new(2001, 1, 1)
    person.member_to = Date.new(2001, 12, 31)
    assert_equal(false, person.member?, 'member?')
    assert_equal(false, person.member?(Date.new(2000, 12, 31)), 'member')
    assert_equal(true, person.member?(Date.new(2001, 1, 1)), 'member')
    assert_equal(true, person.member?(Date.new(2001, 12, 31)), 'member')
    assert_equal(false, person.member?(Date.new(2002, 1, 1)), 'member')
    person.member = true
    assert_equal(true, person.member?, 'member')
    assert_equal(Date.new(2001, 1, 1), person.member_from, 'Member from')
    assert_equal(Date.new(2009, 12, 31), person.member_to, 'Member to')
    
    ASSOCIATION.now = Date.new(2009, 12)
    person.member_from = Date.new(2001, 1, 1)
    person.member_to = Date.new(2001, 12, 31)
    assert_equal(false, person.member?, 'member?')
    assert_equal(false, person.member?(Date.new(2000, 12, 31)), 'member')
    assert_equal(true, person.member?(Date.new(2001, 1, 1)), 'member')
    assert_equal(true, person.member?(Date.new(2001, 12, 31)), 'member')
    assert_equal(false, person.member?(Date.new(2002, 1, 1)), 'member')
    person.member = true
    assert_equal(true, person.member?, 'member')
    assert_equal(Date.new(2001, 1, 1), person.member_from, 'Member from')
    assert_equal(Date.new(2010, 12, 31), person.member_to, 'Member to')

    ASSOCIATION.now = nil
    person.member_from = Date.new(2001, 1, 1)
    person.member_to = Date.new(2001, 12, 31)
    assert_equal(false, person.member?, 'member?')
    person.member = false
    assert_equal(Date.new(2001, 1, 1), person.member_from, 'Member from')
    person.member_to = Date.new(2001, 12, 31)
    assert_equal(false, person.member?, 'member?')
    
    # From in past, to in future
    ASSOCIATION.now = Date.new(2009, 1)
    person.member_from = Date.new(2001, 1, 1)
    person.member_to = Date.new(3000, 12, 31)
    assert_equal(true, person.member?, 'member?')
    person.member = true
    assert_equal(true, person.member?, 'member')
    assert_equal(Date.new(2001, 1, 1), person.member_from, 'Member from')
    assert_equal(Date.new(3000, 12, 31), person.member_to, 'Member to')
    
    person.member = false
    assert_equal(Date.new(2001, 1, 1), person.member_from, 'Member from')
    assert_equal(Date.new(2008, 12, 31), person.member_to, 'Member to')
    assert_equal(false, person.member?, 'member?')

    # From, to in future
    person.member_from = Date.new(2500, 1, 1)
    person.member_to = Date.new(3000, 12, 31)
    assert_equal(false, person.member?, 'member?')
    person.member = true
    assert_equal(true, person.member?, 'member')
    assert_equal_dates(Date.new(2009), person.member_from, 'Member from')
    assert_equal_dates('3000-12-31', person.member_to, 'Member to')
    
    person.member = false
    assert_nil(person.member_from, 'Member on')
    assert_nil(person.member_to, 'Member to')
    assert_equal(false, person.member?, 'member?')
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
    assert_equal_dates(Date.today, person.member_from, 'Member from')
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
    
    person.date_of_birth = Date.new((ASSOCIATION.masters_age - 1).years.ago.year, 1, 1)
    assert(!person.master?, 'Master?')

    person.date_of_birth = Date.new(ASSOCIATION.masters_age.years.ago.year, 12, 31)
    assert(person.master?, 'Master?')
    
    person.date_of_birth = Date.new(17.years.ago.year, 1, 1)
    assert(!person.master?, 'Master?')

    # Greater then 36 or so years in the past will give an ArgumentError on Windows
    person.date_of_birth = Date.new((ASSOCIATION.masters_age + 1).years.ago.year, 12, 31)
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
    person = people(:weaver)
    assert_nil(person.bmx_category, "BMX category")
    person.bmx_category = "H100"
    assert_equal("H100", person.bmx_category, "BMX category")
  end
  
  def test_blank_numbers
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
    tonkin = people(:tonkin)
    assert_equal('102', tonkin.road_number)
    assert_nil(tonkin.dh_number)
    assert_nil(tonkin.ccx_number)
    tonkin.ccx_number = "U89"
    assert_equal("U89", tonkin.ccx_number)
    assert_equal("U89", tonkin.number(:ccx))
    assert_equal("U89", tonkin.number("ccx"))
    assert_equal("U89", tonkin.number("Cyclocross"))
    assert_equal("U89", tonkin.number(Discipline["Cyclocross"]))
    assert_equal "102", tonkin.number("Time Trial")
  end
  
  def test_update
    Person.update(
    people(:alice).id,
    "work_phone"=>"", "date_of_birth(2i)"=>"1", "occupation"=>"engineer", "city"=>"Wilsonville", "cell_fax"=>"", "zip"=>"97070", "date_of_birth(3i)"=>"1", "mtb_category"=>"Spt", "member_from(1i)"=>"2005", "dh_category"=>"", "member_from(2i)"=>"12", "member_from(3i)"=>"17", "member"=>"1", "gender"=>"M", "notes"=>"rm", "ccx_category"=>"", "team_name"=>"", "road_category"=>"5", "xc_number"=>"1061", "street"=>"31153 SW Willamette Hwy W", "track_category"=>"", "home_phone"=>"503-582-8823", "dh_number"=>"917", "road_number"=>"2051", "first_name"=>"Paul", "ccx_number"=>"112", "last_name"=>"Formiller", "date_of_birth(1i)"=>"1969", "email"=>"paul.formiller@verizon.net", "state"=>"OR"
    )
    assert_equal('917', people(:alice).dh_number, 'downhill_number')
    assert_equal('112', people(:alice).ccx_number, 'ccx_number')
  end
  
  def test_date
    person = Person.new(:date_of_birth => '0073-10-04')
    assert_equal_dates('1973-10-04', person.date_of_birth, 'date_of_birth from 0073-10-04')

    person = Person.new(:date_of_birth => "10/27/78")
    assert_equal_dates('1978-10-27', person.date_of_birth, 'date_of_birth from 10/27/78')

    person = Person.new(:date_of_birth => "78")
    assert_equal_dates('1978-01-01', person.date_of_birth, 'date_of_birth from 78')
  end
  
  def test_birthdate
    person = Person.new(:date_of_birth => '1973-10-04')
    assert_equal_dates('1973-10-04', person.date_of_birth, 'date_of_birth from 0073-10-04')
    assert_equal_dates('1973-10-04', person.birthdate, 'birthdate from 0073-10-04')
  end
  
  def test_find_by_number
    person = Person.find_by_number('340')
    assert_equal([people(:matson)], person, 'Should find Matson')
  end
  
  def test_find_all_by_name_like
    assert_equal([], Person.find_all_by_name_like("foo123"), "foo123 should find no names")
    weaver = people(:weaver)
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
  
  def test_hometown
    person = Person.new
    assert_equal('', person.hometown, 'New Person hometown')
    
    person.city = 'Newport'
    assert_equal('Newport', person.hometown, 'Person hometown')
    
    person.city = nil
    person.state = ASSOCIATION.state
    assert_equal('', person.hometown, 'Person hometown')
    
    person.city = 'Fossil'
    person.state = ASSOCIATION.state
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
    assert_not_nil(Person.find_by_name('Molly Cameron'), 'Molly Cameron should exist')
    assert_not_nil(Alias.find_by_name('Mollie Cameron'), 'Mollie Cameron alias should exist')
    assert_nil(Person.find_by_name('Mollie Cameron'), 'Mollie Cameron should not exist')

    molly = people(:molly)
    molly.name = 'Mollie Cameron'
    molly.save!
    assert(molly.valid?, 'Renamed Mollie Cameron should be valid')
    
    assert_not_nil(Person.find_by_name('Mollie Cameron'), 'Mollie Cameron should exist')
    assert_nil(Person.find_by_name('Molly Cameron'), 'Molly Cameron should not exist')
    assert_nil(Alias.find_by_name('Mollie Cameron'), 'Mollie Cameron alias should not exist')
    assert_not_nil(Alias.find_by_name('Molly Cameron'), 'Molly Cameron alias should exist')
  end
  
  def test_sort
    r1 = Person.new
    r1.id = 1
    r2 = Person.new
    r2.id = 2
    r3 = Person.new
    r3.id = 3
    
    people = [r2, r1, r3]
    people.sort!
    
    assert_equal([r1, r2, r3], people, 'sorted')
  end
  
  def test_find_all_current_email_addresses
    email = Person.find_all_current_email_addresses
    expected = [
      "Bob Jones <member@example.com>",
      "Mark Matson <mcfatson@gentlelovers.com>",
      "Ryan Weaver <hotwheels@yahoo.com>"
    ]
    assert_equal(expected, email, "email addresses")
  end
  
  def test_add_number
    person = Person.create!
    person.add_number("7890", nil)
    assert_equal("7890", person.road_number, "Road number after add with nil discipline")    
  end
  
  def test_add_number_from_non_number_discipline
    person = Person.create!
    circuit_race = Discipline[:circuit]
    person.add_number("7890", circuit_race)
    assert_equal("7890", person.road_number, "Road number after add with nil discipline")
    assert_equal("7890", person.number(circuit_race), "Circuit race number after add with nil discipline")
  end
  
  # Legacy test … used to look at data to devine creator
  def test_created_from_result?
    person = Person.create!
    assert(!person.created_from_result?, "created_from_result? for blank Person")

    person = Person.create!(:name => "Some Person")
    assert(!person.created_from_result?, "created_from_result? for Person with just name")

    person = Person.create!(:name => "Some Person", :team => teams(:gentle_lovers))
    assert(!person.created_from_result?, "created_from_result? for Person with just name and team")

    person = Person.create!(:name => "Some Person", :team => teams(:gentle_lovers), :email => "person@example.com")
    assert(!person.created_from_result?, "created_from_result? for Person with name and team and email")

    person = Person.create!(:name => "Some Person", :team => teams(:gentle_lovers), :home_phone => "911")
    assert(!person.created_from_result?, "created_from_result? for Person with name and team and phone")

    person = Person.create!(:name => "Some Person", :team => teams(:gentle_lovers), :street => "10 Main Street")
    assert(!person.created_from_result?, "created_from_result? for Person with name and team and street")
  end
  
  def test_people_with_same_name
   assert_equal([], people(:molly).people_with_same_name, "No other people named 'Molly Cameron'")

   person = people(:molly)
   person.name = "Mollie Cameron"
   person.save!
   assert_equal([], people(:molly).people_with_same_name, "No other people named 'Mollie Cameron'")
   
   Person.create!(:name => "Mollie Cameron")
   assert_equal(1, people(:molly).people_with_same_name.size, "Other people named 'Mollie Cameron'")
  end
  
  def test_dh_number_with_no_downhill_discipline
   Discipline.find_by_name("Downhill").destroy
   Discipline.reset
   
   assert(!Discipline.exists?(:name => "Downhill"), "Downhill should be deleted")
   assert_nil(people(:alice).dh_number, "DH number")
  end
  
  def test_find_all_by_name_or_alias
    new_tonkin = Person.create!(:name => "Erik Tonkin")
    assert_equal(2, Person.find_all_by_name("Erik Tonkin").size, "Should have 2 Tonkins")
    assert_equal(2, Person.find_all_by_name_or_alias(:first_name => "Erik", :last_name => "Tonkin").size, "Should have 2 Tonkins")
    assert_raise(ArgumentError) { Person.find_all_by_name("Erik", "Tonkin") }
  end
  
  def test_find_all_for_export
    people = Person.find_all_for_export
    assert_equal("Molly", people[0]["first_name"], "Row 0 first_name")
    assert_equal("Kona", people[2]["team_name"], "Row 2 team")
    assert_equal("30", people[4]["racing_age"], "Row 4 racing_age")
    assert_equal("01/01/1999", people[4]["member_from"], "Row 4 member_from")
    assert_equal("12/31/#{Date.today.year}", people[4]["member_to"], "Row 4 member_to")
    assert_equal("5", people[4]["track_category"], "Row 4 track_category")
  end
  
  def test_create
    Person.create!(:name => 'Mr. Tuxedo', :password =>'blackcat', :password_confirmation =>'blackcat', :email => "tuxedo@example.com")
  end
  
  def test_find_by_info
    assert_equal(people(:promoter), Person.find_by_info("Brad ross"))
    assert_equal(people(:promoter), Person.find_by_info("Brad ross", "brad@foo.com"))
    assert_equal(people(:administrator), Person.find_by_info("Candi Murray"))
    assert_equal(people(:administrator), Person.find_by_info("Candi Murray", "admin@example.com", "(503) 555-1212"))
    assert_equal(people(:administrator), Person.find_by_info("", "admin@example.com", "(503) 555-1212"))
    assert_equal(people(:administrator), Person.find_by_info("", "admin@example.com"))

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
    Person.create!
  end
  
  def test_save_no_name
    Person.create!(:email => "nate@six-hobsons.net")
    assert(Person.new(:email => "nate@six-hobsons.net").valid?, "Dupe email addresses allowed")
  end
  
  def test_save_no_email
    Person.create!(:name => "Nate Hobson")
    Person.create!(:name => "Nate Hobson")
  end
  
  def test_events
    assert(!people(:administrator).events.empty?, 'Person Candi should have events')
    assert(Person.create(:name => 'New').events.empty?, 'New promoter should not have events')
  end
  
  def test_administrator
    assert(people(:administrator).administrator?, 'administrator administrator?')
    assert(!people(:promoter).administrator?, 'administrator administrator?')
    assert(!people(:member).administrator?, 'administrator administrator?')
    assert(!people(:nate_hobson).administrator?, 'administrator administrator?')
  end
  
  def test_promoter
    assert(people(:administrator).promoter?, 'administrator promoter?')
    assert(people(:promoter).promoter?, 'administrator promoter?')
    assert(!people(:member).promoter?, 'administrator promoter?')
    assert(!people(:nate_hobson).promoter?, 'administrator promoter?')
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
    person = Person.create!(:password => "", :password_confirmation => "", :login => "")
    person.reload
    assert_nil person.login, "login should be nil, not blank"
  end
  
  def test_authlogic_should_not_set_updated_at_on_load
    person = Person.create!(:name => "Joe Racer", :updated_at => '2008-10-01')
    assert_equal_dates "2008-10-01", person.updated_at, "updated_at"
    person = Person.find(person.id)
    assert_equal_dates "2008-10-01", person.updated_at, "updated_at"
  end
  
  def test_renewed
    person = Person.create!
    assert !person.renewed?, "New person"

    ASSOCIATION.now = Date.new(2009, 11, 30)
    person = Person.create!(:member_from => Date.new(2009, 1, 1), :member_to => Date.new(2009, 12, 31))
    assert person.renewed?, "Before Dec 1"

    ASSOCIATION.now = Date.new(2009, 12, 1)
    person = Person.create!(:member_from => Date.new(2009, 1, 1), :member_to => Date.new(2009, 12, 31))
    assert !person.renewed?, "On Dec 1"
  end
  
  # member_from: nil, past, future, > October, < October, end of year, next year, far in future
  # member_to: nil, past, future, > October, < October, end of year, next year, far in future
  # now: start of year, < October, > October, end of year
  def test_renew
    # assert_renew(Time.local(2008, 1), nil, nil, Time.local(2008, 1), Time.local(2008, 12, 31))
    # assert_renew(Time.local(2008, 8), nil, nil, Time.local(2008, 8), Time.local(2008, 12, 31))
    # assert_renew(Time.local(2008, 11), nil, nil, Time.local(2008, 11), Time.local(2008, 12, 31))
    # assert_renew(Time.local(2008, 12, 31), nil, nil, Time.local(2008, 12, 31), Time.local(2008, 12, 31))
    # 
    # person = Person.new(:member_from => Time.local(2004))
    # now = Time.local(2008, 1).to_date
    # person.renew(now)
    # assert_equal true, person.member?(now), "member?"
    # assert_equal_dates Time.local(2004, 1, 1), person.member_from, "member_from"
    # assert_equal_dates Time.local(2008, 12, 31), person.member_to, "member_to"
    # 
    # person = Person.new(:member_from => Time.local(2012))
    # now = Time.local(2008, 1).to_date
    # person.renew(now)
    # assert_equal true, person.member?(now), "member?"
    # assert_equal_dates Time.local(2008, 1, 1), person.member_from, "member_from"
    # assert_equal_dates Time.local(2008, 12, 31), person.member_to, "member_to"
    # 
    # person = Person.new(:member_from => Time.local(2008, 11))
    # now = Time.local(2008, 11).to_date
    # person.renew(now)
    # assert_equal true, person.member?(now), "member?"
    # assert_equal_dates Time.local(2008, 11), person.member_from, "member_from"
    # assert_equal_dates Time.local(2008, 12, 31), person.member_to, "member_to"
    # 
    # person = Person.new(:member_from => Time.local(2008, 11))
    # now = Time.local(2008, 3).to_date
    # person.renew(now)
    # assert_equal true, person.member?(now), "member?"
    # assert_equal_dates Time.local(2008, 3), person.member_from, "member_from"
    # assert_equal_dates Time.local(2008, 12, 31), person.member_to, "member_to"
    # 
    # person = Person.new(:member_from => Time.local(2008, 12, 31))
    # now = Time.local(2008, 12, 31).to_date
    # person.renew(now)
    # assert_equal true, person.member?(now), "member?"
    # assert_equal_dates Time.local(2008, 3), person.member_from, "member_from"
    # assert_equal_dates Time.local(2008, 12, 31), person.member_to, "member_to"
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
