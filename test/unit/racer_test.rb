require File.dirname(__FILE__) + '/../test_helper'

class RacerTest < ActiveSupport::TestCase

  def test_save
    assert_nil(Racer.find_by_last_name("Hampsten"), "Hampsten should not be in DB")
    assert_nil(Team.find_by_name("7-11"), "7-11 should not be in DB")
    
    racer = Racer.new(:last_name => "Hampsten")
    team = Team.new(:name => "7-11")
    
    racer.team = team
    racer.save!
    
    racer_from_db = Racer.find_by_last_name("Hampsten")
    assert_not_nil(racer_from_db, "Hampsten should  be  DB")
    assert_not_nil(Team.find_by_name("7-11"), "7-11 should be in DB")
    assert_equal(racer.team, racer_from_db.team, "racer.team")
    racer.reload
    assert_equal(racer.team, racer_from_db.team, "racer.team")
    assert(!racer.team.new_record?, "team.new_record")
    assert(!racer_from_db.new_record?, "racer_from_db.new_record")
  end

  def test_save_existing_team
    assert_nil(Racer.find_by_last_name("Hampsten"), "Hampsten should not be in DB")
    assert_not_nil(Team.find_by_name("Vanilla"), "Vanilla should be in DB")
    
    racer = Racer.new(:last_name => "Hampsten")
    team = Team.new(:name => "Vanilla")
    
    racer.team = team
    racer.save!
    assert_equal(racer.team, Team.find_by_name("Vanilla"), 'Vanilla from DB')
    racer.reload
    assert_equal(racer.team, Team.find_by_name("Vanilla"), 'Vanilla from DB')
  end

  def test_new
    racer = Racer.create!(
      :date_of_birth => '1970-12-31',
      :cell_fax => '(315) 342-1313',
      :city => "Santa Rosa", 
      :ccx_category => 'A', 
      :dh_category => 'Novice', 
      :dh_number => "100", 
      :email => 'andy@pig_bikes.com',
      :first_name => 'Andy',
      :gender => 'M',
      :home_phone => '(315) 221-4774',
      :last_name => "Hampsten", 
      :license => "125162", 
      :mtb_category => 'Expert', 
      :notes => 'Won Giro', 
      :member_from => '2001-07-19', 
      :road_number => "300", 
      :occupation => 'Vinter', 
      :road_category => '1', 
      :state => "CA", 
      :street => "5 Burr Street", 
      :team => {:name => "7-11"},
      :track_category => '2', 
      :work_phone => '(315) 444-1022',
      :xc_number => "101",
      :zip => "13035"
    )
    assert_equal_dates("1970-12-31", racer.date_of_birth, "date_of_birth")
    assert_equal("(315) 342-1313", racer.cell_fax, "cell_fax")
    assert_equal("A", racer.ccx_category, "ccx_category")
    assert_equal("Novice", racer.dh_category, "dh_category")
    assert_equal("(315) 221-4774", racer.home_phone, "home_phone")
    assert_equal("Expert", racer.mtb_category, "mtb_category")
    assert_equal_dates("2001-07-19", racer.member_from, "member_from")
    assert_equal("Vinter", racer.occupation, "occupation")
    assert_equal("1", racer.road_category, "road_category")
    assert_equal("2", racer.track_category, "track_category")
    assert_equal("101", racer.xc_number, "xc_number")
    assert_equal("Santa Rosa", racer.city, "city")
    assert_equal("100", racer.dh_number, "dh_number")
    assert_equal("andy@pig_bikes.com", racer.email, "email")
    assert_equal("M", racer.gender, "gender")
    assert_equal("125162", racer.license, "license")
    assert_equal("Andy Hampsten", racer.name, "name")
    assert_equal("Won Giro", racer.notes, "notes")
    assert_not_nil(racer.road_number, "road_number")
    assert_equal("300", racer.road_number, "road_number")
    assert_equal("CA", racer.state, "state")
    assert_equal("5 Burr Street", racer.street, "street")
    assert_equal("7-11", racer.team.name, "team.name")
    assert_equal("101", racer.xc_number, "xc_number")
    assert_equal("13035", racer.zip, "xc_number")
    assert_equal(false, racer.print_card, 'print_card')
    assert_equal(false, racer.print_card?, 'print_card?')
    assert_equal(false, racer.print_mailing_label, 'print_mailing_label')
    assert_equal(false, racer.print_mailing_label?, 'print_mailing_label?')
    assert_equal(false, racer.ccx_only, 'ccx_only')
    assert_equal(false, racer.ccx_only?, 'ccx_only?')
    
    for number in racer.race_numbers(true)
      assert(number.valid?, "#{number}: #{number.errors.full_messages}")
    end
    racer.save!
    racer.reload
    
    assert_equal_dates("1970-12-31", racer.date_of_birth, "date_of_birth")
    assert_equal("(315) 342-1313", racer.cell_fax, "cell_fax")
    assert_equal("A", racer.ccx_category, "ccx_category")
    assert_equal("Novice", racer.dh_category, "dh_category")
    assert_equal("(315) 221-4774", racer.home_phone, "home_phone")
    assert_equal("Expert", racer.mtb_category, "mtb_category")
    assert_equal_dates("2001-07-19", racer.member_from, "member_from")
    assert_equal("Vinter", racer.occupation, "occupation")
    assert_equal("1", racer.road_category, "road_category")
    assert_equal("2", racer.track_category, "track_category")
    assert_equal("101", racer.xc_number, "xc_number")
    assert_equal("Santa Rosa", racer.city, "city")
    assert_equal("100", racer.dh_number, "dh_number")
    assert_equal("andy@pig_bikes.com", racer.email, "email")
    assert_equal("M", racer.gender, "gender")
    assert_equal("125162", racer.license, "license")
    assert_equal("Andy Hampsten", racer.name, "name")
    assert_equal("Won Giro", racer.notes, "notes")
    assert_equal("300", racer.road_number(true), "road_number")
    assert_equal("CA", racer.state, "state")
    assert_equal("5 Burr Street", racer.street, "street")
    assert_equal("7-11", racer.team.name, "team.name")
    assert_equal("101", racer.xc_number, "xc_number")
    assert_equal("13035", racer.zip, "xc_number")
  end
 
  def test_merge
    racer_to_keep = racers(:molly)
    racer_to_merge = racers(:tonkin)
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_keep.first_name, racer_to_keep.last_name), "#{racer_to_keep.name} should be in DB")
    assert_equal(3, Result.find_all_by_racer_id(racer_to_keep.id).size, "Molly's results")
    assert_equal(1, Alias.find_all_by_racer_id(racer_to_keep.id).size, "Mollys's aliases")
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_merge.first_name, racer_to_merge.last_name), "#{racer_to_merge.name} should be in DB")
    assert_equal(2, Result.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's results")
    assert_equal(1, Alias.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's aliases")
    
    racer_to_keep.merge(racer_to_merge)
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_keep.first_name, racer_to_keep.last_name), "#{racer_to_keep.name} should be in DB")
    assert_equal(5, Result.find_all_by_racer_id(racer_to_keep.id).size, "Molly's results")
    aliases = Alias.find_all_by_racer_id(racer_to_keep.id)
    erik_alias = aliases.detect{|a| a.name == 'Erik Tonkin'}
    assert_not_nil(erik_alias, 'Molly should have Erik Tonkin alias')
    assert_equal(3, Alias.find_all_by_racer_id(racer_to_keep.id).size, "Molly's aliases")
    
    assert_nil(Racer.find_by_first_name_and_last_name(racer_to_merge.first_name, racer_to_merge.last_name), "#{racer_to_merge.name} should not be in DB")
    assert_equal(0, Result.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's results")
    assert_equal(0, Alias.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's aliases")
  end
  
  def test_merge_no_alias_dup_names
    racer_to_keep = racers(:molly)
    racer_to_merge = racers(:tonkin)
    racer_same_name_as_merged = Racer.create(:name => racer_to_merge.name, :road_number => 'YYZ')
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_keep.first_name, racer_to_keep.last_name), "#{racer_to_keep.name} should be in DB")
    assert_equal(3, Result.find_all_by_racer_id(racer_to_keep.id).size, "Molly's results")
    assert_equal(1, Alias.find_all_by_racer_id(racer_to_keep.id).size, "Mollys's aliases")
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_merge.first_name, racer_to_merge.last_name), "#{racer_to_merge.name} should be in DB")
    assert_equal(2, Result.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's results")
    assert_equal(1, Alias.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's aliases")
    
    racer_to_keep.merge(racer_to_merge)
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_keep.first_name, racer_to_keep.last_name), "#{racer_to_keep.name} should be in DB")
    assert_equal(5, Result.find_all_by_racer_id(racer_to_keep.id).size, "Molly's results")
    aliases = Alias.find_all_by_racer_id(racer_to_keep.id)
    erik_alias = aliases.detect{|a| a.name == 'Erik Tonkin'}
    assert_nil(erik_alias, 'Molly should not have Erik Tonkin alias because there is another Erik Tonkin')
    assert_equal(2, Alias.find_all_by_racer_id(racer_to_keep.id).size, "Molly's aliases")
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_merge.first_name, racer_to_merge.last_name), "#{racer_to_merge.name} should still be in DB")
    assert_equal(0, Result.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's results")
    assert_equal(0, Alias.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's aliases")
  end

  def test_name
    racer = Racer.new(:first_name => 'Dario', :last_name => 'Frederick')
    assert_equal(racer.name, 'Dario Frederick', 'name')
    racer.name = ''
    assert_equal(racer.name, '', 'name')
  end
  
  def test_member
    racer = Racer.new(:first_name => 'Dario', :last_name => 'Frederick')
    assert_equal(false, racer.member?, 'member')
    assert_nil(racer.member_from, 'Member from')
    assert_nil(racer.member_to, 'Member to')
    
    racer.save!
    racer.reload
    assert_equal(false, racer.member?, 'member')
    assert_nil(racer.member_from, 'Member on')
    assert_nil(racer.member_to, 'Member to')

    racer.member = true
    assert_equal(true, racer.member?, 'member')
    assert_equal(Date.today, racer.member_from, 'Member on')
    year = Date.today.year
    assert_equal(Date.new(year, 12, 31), racer.member_to, 'Member to')
    racer.save!
    racer.reload
    assert_equal(true, racer.member?, 'member')
    assert_equal(Date.today, racer.member_from, 'Member on')
    year = Date.today.year
    assert_equal(Date.new(year, 12, 31), racer.member_to, 'Member to')
    
    racer.member = false
    assert_equal(false, racer.member?, 'member')
    assert_nil(racer.member_from, 'Member on')
    assert_nil(racer.member_to, 'Member to')
    racer.save!
    racer.reload
    assert_equal(false, racer.member?, 'member')
    assert_nil(racer.member_from, 'Member on')
    assert_nil(racer.member_to, 'Member to')
    
    # From nil, to nil
    racer.member_from = nil
    racer.member_to = nil
    assert_equal(false, racer.member?, 'member?')
    racer.member = true
    assert_equal(true, racer.member?, 'member')
    assert_equal(Date.today, racer.member_from, 'Member from')
    assert_equal(Date.new(year, 12, 31), racer.member_to, 'Member to')
    
    racer.member_from = nil
    racer.member_to = nil
    assert_equal(false, racer.member?, 'member?')
    racer.member = false
    racer.member_from = nil
    racer.member_to = nil
    assert_equal(false, racer.member?, 'member?')
    
    # From, to in past
    racer.member_from = Date.new(2001, 1, 1)
    racer.member_to = Date.new(2001, 12, 31)
    assert_equal(false, racer.member?, 'member?')
    assert_equal(false, racer.member?(Date.new(2000, 12, 31)), 'member')
    assert_equal(true, racer.member?(Date.new(2001, 1, 1)), 'member')
    assert_equal(true, racer.member?(Date.new(2001, 12, 31)), 'member')
    assert_equal(false, racer.member?(Date.new(2002, 1, 1)), 'member')
    racer.member = true
    assert_equal(true, racer.member?, 'member')
    assert_equal(Date.new(2001, 1, 1), racer.member_from, 'Member from')
    assert_equal(Date.new(year, 12, 31), racer.member_to, 'Member to')
    
    racer.member_from = Date.new(2001, 1, 1)
    racer.member_to = Date.new(2001, 12, 31)
    assert_equal(false, racer.member?, 'member?')
    racer.member = false
    assert_equal(Date.new(2001, 1, 1), racer.member_from, 'Member from')
    racer.member_to = Date.new(2001, 12, 31)
    assert_equal(false, racer.member?, 'member?')
    
    # From in past, to in future
    racer.member_from = Date.new(2001, 1, 1)
    racer.member_to = Date.new(3000, 12, 31)
    assert_equal(true, racer.member?, 'member?')
    racer.member = true
    assert_equal(true, racer.member?, 'member')
    assert_equal(Date.new(2001, 1, 1), racer.member_from, 'Member from')
    assert_equal(Date.new(3000, 12, 31), racer.member_to, 'Member to')
    
    racer.member = false
    assert_equal(Date.new(2001, 1, 1), racer.member_from, 'Member from')
    assert_equal(Date.new(year - 1, 12, 31), racer.member_to, 'Member to')
    assert_equal(false, racer.member?, 'member?')

    # From, to in future
    racer.member_from = Date.new(2500, 1, 1)
    racer.member_to = Date.new(3000, 12, 31)
    assert_equal(false, racer.member?, 'member?')
    racer.member = true
    assert_equal(true, racer.member?, 'member')
    assert_equal_dates(Date.today, racer.member_from, 'Member from')
    assert_equal_dates('3000-12-31', racer.member_to, 'Member to')
    
    racer.member = false
    assert_nil(racer.member_from, 'Member on')
    assert_nil(racer.member_to, 'Member to')
    assert_equal(false, racer.member?, 'member?')
  end
  
  def test_member_in_year
    racer = Racer.new(:first_name => 'Dario', :last_name => 'Frederick')
    assert_equal(false, racer.member_in_year?, 'member_in_year')
    assert_nil(racer.member_from, 'Member from')
    assert_nil(racer.member_to, 'Member to')

    racer.member = true
    assert_equal(true, racer.member_in_year?, 'member_in_year')
    racer.save!
    racer.reload
    assert_equal(true, racer.member_in_year?, 'member_in_year')
    
    racer.member = false
    assert_equal(false, racer.member_in_year?, 'member_in_year')
    racer.save!
    racer.reload
    assert_equal(false, racer.member_in_year?, 'member_in_year')

    # From, to in past
    racer.member_from = Date.new(2001, 1, 1)
    racer.member_to = Date.new(2001, 12, 31)
    assert_equal(false, racer.member_in_year?, 'member_in_year?')
    assert_equal(false, racer.member_in_year?(Date.new(2000, 12, 31)), 'member')
    assert_equal(true, racer.member_in_year?(Date.new(2001, 1, 1)), 'member')
    assert_equal(true, racer.member_in_year?(Date.new(2001, 12, 31)), 'member')
    assert_equal(false, racer.member_in_year?(Date.new(2002, 1, 1)), 'member')

    racer.member_from = Date.new(2001, 4, 2)
    racer.member_to = Date.new(2001, 6, 10)
    assert_equal(false, racer.member_in_year?, 'member_in_year?')
    assert_equal(false, racer.member_in_year?(Date.new(2000, 12, 31)), 'member')
    assert_equal(true, racer.member_in_year?(Date.new(2001, 4, 1)), 'member')
    assert_equal(true, racer.member_in_year?(Date.new(2001, 4, 2)), 'member')
    assert_equal(true, racer.member_in_year?(Date.new(2001, 6, 10)), 'member')
    assert_equal(true, racer.member_in_year?(Date.new(2001, 6, 11)), 'member')
    assert_equal(false, racer.member_in_year?(Date.new(2002, 1, 1)), 'member')
  end
  
  def test_member_to
    # from = nil, to = nil
    racer = Racer.new(:first_name => 'Dario', :last_name => 'Frederick')
    racer.member_from = nil
    racer.member_to = nil
    assert_equal(false, racer.member?, 'member?')
    assert_nil(racer.member_from, 'member_from')
    assert_nil(racer.member_to, 'member_to')
    
    racer.member_to = Date.new(3000, 12, 31)
    assert_equal_dates(Date.today, racer.member_from, 'Member from')
    assert_equal_dates('3000-12-31', racer.member_to, 'Member to')
    assert_equal(true, racer.member?, 'member?')

    # before, before
    racer = Racer.new(:first_name => 'Dario', :last_name => 'Frederick')
    racer.member_from = Date.new(1970, 1, 1)
    racer.member_to = Date.new(1970, 12, 31)

    racer.member_to = Date.new(1971, 7, 31)
    assert_equal_dates(Date.new(1970, 1, 1), racer.member_from, 'Member from')
    assert_equal_dates('1971-07-31', racer.member_to, 'Member to')
    assert_equal(false, racer.member?, 'member?')

    # before, after
    racer = Racer.new(:first_name => 'Dario', :last_name => 'Frederick')
    racer.member_from = Date.new(1970, 1, 1)
    racer.member_to = Date.new(1985, 12, 31)

    racer.member_to = Date.new(1971, 7, 31)
    assert_equal_dates(Date.new(1970, 1, 1), racer.member_from, 'Member from')
    assert_equal_dates('1971-07-31', racer.member_to, 'Member to')
    assert_equal(false, racer.member?, 'member?')

    # after, after
    racer = Racer.new(:first_name => 'Dario', :last_name => 'Frederick')
    racer.member_from = Date.new(2006, 1, 1)
    racer.member_to = Date.new(2006, 12, 31)

    racer.member_to = Date.new(2000, 1, 31)
    assert_equal_dates(Date.new(2000, 1, 31), racer.member_from, 'Member from')
    assert_equal_dates('2000-01-31', racer.member_to, 'Member to')
    assert_equal(false, racer.member?, 'member?')
  end
  
  def test_team_name
    racer = Racer.new(:first_name => 'Dario', :last_name => 'Frederick')
    assert_equal(racer.team_name, '', 'name')

    racer.team_name = 'Vanilla'
    assert_equal('Vanilla', racer.team_name, 'name')

    racer.team_name = 'Pegasus'
    assert_equal('Pegasus', racer.team_name, 'name')

    racer.team_name = ''
    assert_equal('', racer.team_name, 'name')
  end
  
  def test_duplicate
    Racer.create(:first_name => 'Otis', :last_name => 'Guy')
    racer = Racer.new(:first_name => 'Otis', :last_name => 'Guy')
    assert(racer.valid?, 'Dupe racer name with no number should be valid')

    racer = Racer.new(:first_name => 'Otis', :last_name => 'Guy', :road_number => '180')
    assert(racer.valid?, 'Dupe racer name valid even if racer has no numbers')

    Racer.create(:first_name => 'Otis', :last_name => 'Guy', :ccx_number => '180')
    Racer.create(:first_name => 'Otis', :last_name => 'Guy', :ccx_number => '19')
  end
  
  def test_master?
    racer = Racer.new
    assert(!racer.master?, 'Master?')
    
    racer.date_of_birth = Date.new(29.years.ago.year, 1, 1)
    assert(!racer.master?, 'Master?')

    racer.date_of_birth = Date.new(30.years.ago.year, 12, 31)
    assert(racer.master?, 'Master?')
    
    racer.date_of_birth = Date.new(17.years.ago.year, 1, 1)
    assert(!racer.master?, 'Master?')

    # Greater then 36 or so years in the past will give an ArgumentError on Windows
    racer.date_of_birth = Date.new(36.years.ago.year, 12, 31)
    assert(racer.master?, 'Master?')
  end
  
  def test_junior?
    racer = Racer.new
    assert(!racer.junior?, 'Junior?')
    
    racer.date_of_birth = Date.new(19.years.ago.year, 1, 1)
    assert(!racer.junior?, 'Junior?')

    racer.date_of_birth = Date.new(18.years.ago.year, 12, 31)
    assert(racer.junior?, 'Junior?')
    
    racer.date_of_birth = Date.new(21.years.ago.year, 1, 1)
    assert(!racer.junior?, 'Junior?')

    racer.date_of_birth = Date.new(12.years.ago.year, 12, 31)
    assert(racer.junior?, 'Junior?')
  end
  
  def test_racing_age
    racer = Racer.new
    assert_nil(racer.racing_age)

    racer.date_of_birth = 29.years.ago
    assert_equal(29, racer.racing_age, 'racing_age')

    racer.date_of_birth = Date.new(29.years.ago.year, 1, 1)
    assert_equal(29, racer.racing_age, 'racing_age')

    racer.date_of_birth = Date.new(29.years.ago.year, 12, 31)
    assert_equal(29, racer.racing_age, 'racing_age')

    racer.date_of_birth = Date.new(30.years.ago.year, 12, 31)
    assert_equal(30, racer.racing_age, 'racing_age')

    racer.date_of_birth = Date.new(28.years.ago.year, 1, 1)
    assert_equal(28, racer.racing_age, 'racing_age')
  end
  
  def test_bmx_category
    racer = racers(:weaver)
    assert_nil(racer.bmx_category, "BMX category")
    racer.bmx_category = "H100"
    assert_equal("H100", racer.bmx_category, "BMX category")
  end
  
  def test_blank_numbers
    racer = Racer.new
    assert_nil(racer.ccx_number, 'cross number after new')
    assert_nil(racer.dh_number, 'dh number after new')
    assert_nil(racer.road_number, 'road number after new')
    assert_nil(racer.track_number, 'track number after new')
    assert_nil(racer.xc_number, 'xc number after new')
    
    racer.save!
    racer.reload
    assert_nil(racer.ccx_number, 'cross number after save')
    assert_nil(racer.dh_number, 'dh number after save')
    assert_nil(racer.road_number, 'road number after save')
    assert_nil(racer.track_number, 'track number after save')
    assert_nil(racer.xc_number, 'xc number after save')
    
    racer = Racer.update(
      racer.id, 
      :ccx_number => '',
      :dh_number => '',
      :road_number => '',
      :track_number => '',
      :xc_number => ''
    )
    assert_nil(racer.ccx_number, 'cross number after update with empty string')
    assert_nil(racer.dh_number, 'dh number after update with empty string')
    assert_nil(racer.road_number, 'road number after update with empty string')
    assert_nil(racer.track_number, 'track number after update with empty string')
    assert_nil(racer.xc_number, 'xc number after update with empty string')
   
    racer.reload
    assert_nil(racer.ccx_number, 'cross number after update with empty string')
    assert_nil(racer.dh_number, 'dh number after update with empty string')
    assert_nil(racer.road_number, 'road number after update with empty string')
    assert_nil(racer.track_number, 'track number after update with empty string')
    assert_nil(racer.xc_number, 'xc number after update with empty string')
  end
  
  def test_numbers
    tonkin = racers(:tonkin)
    assert_equal('102', tonkin.road_number)
    assert_nil(tonkin.dh_number)
    assert_nil(tonkin.ccx_number)
    tonkin.ccx_number = "U89"
    assert_equal("U89", tonkin.ccx_number)
  end
  
  def test_update
    Racer.update(
    racers(:alice).id,
    "work_phone"=>"", "date_of_birth(2i)"=>"1", "occupation"=>"engineer", "city"=>"Wilsonville", "cell_fax"=>"", "zip"=>"97070", "date_of_birth(3i)"=>"1", "mtb_category"=>"Spt", "member_from(1i)"=>"2005", "dh_category"=>"", "member_from(2i)"=>"12", "member_from(3i)"=>"17", "member"=>"1", "gender"=>"M", "notes"=>"rm", "ccx_category"=>"", "team_name"=>"", "road_category"=>"5", "xc_number"=>"1061", "street"=>"31153 SW Willamette Hwy W", "track_category"=>"", "home_phone"=>"503-582-8823", "dh_number"=>"917", "road_number"=>"2051", "first_name"=>"Paul", "ccx_number"=>"112", "last_name"=>"Formiller", "date_of_birth(1i)"=>"1969", "email"=>"paul.formiller@verizon.net", "state"=>"OR"
    )
    assert_equal('917', racers(:alice).dh_number, 'downhill_number')
    assert_equal('112', racers(:alice).ccx_number, 'ccx_number')
  end
  
  def test_date
    racer = Racer.new(:date_of_birth => '0073-10-04')
    assert_equal_dates('1973-10-04', racer.date_of_birth, 'date_of_birth from 0073-10-04')

    racer = Racer.new(:date_of_birth => "10/27/78")
    assert_equal_dates('1978-10-27', racer.date_of_birth, 'date_of_birth from 10/27/78')

    racer = Racer.new(:date_of_birth => "78")
    assert_equal_dates('1978-01-01', racer.date_of_birth, 'date_of_birth from 78')
  end
  
  def test_birthdate
    racer = Racer.new(:date_of_birth => '1973-10-04')
    assert_equal_dates('1973-10-04', racer.date_of_birth, 'date_of_birth from 0073-10-04')
    assert_equal_dates('1973-10-04', racer.birthdate, 'birthdate from 0073-10-04')
  end
  
  def test_find_by_number
    racer = Racer.find_by_number('340')
    assert_equal([racers(:matson)], racer, 'Should find Matson')
  end
  
  def test_find_all_by_name_like
    assert_equal([], Racer.find_all_by_name_like("foo123"), "foo123 should find no names")
    weaver = racers(:weaver)
    assert_equal([weaver], Racer.find_all_by_name_like("eav"), "'eav' should find Weaver")

    weaver.last_name = "O'Weaver"
    weaver.save!
    assert_equal([weaver], Racer.find_all_by_name_like("eav"), "'eav' should find O'Weaver")
    assert_equal([weaver], Racer.find_all_by_name_like("O'Weaver"), "'O'Weaver' should find O'Weaver")

    weaver.last_name = "Weaver"
    weaver.save!
    Alias.create!(:name => "O'Weaver", :racer => weaver)
    assert_equal([weaver], Racer.find_all_by_name_like("O'Weaver"), "'O'Weaver' should find O'Weaver via alias")
  end
  
  def test_hometown
    racer = Racer.new
    assert_equal('', racer.hometown, 'New Racer hometown')
    
    racer.city = 'Newport'
    assert_equal('Newport', racer.hometown, 'Racer hometown')
    
    racer.city = nil
    racer.state = ASSOCIATION.state
    assert_equal('', racer.hometown, 'Racer hometown')
    
    racer.city = 'Fossil'
    racer.state = ASSOCIATION.state
    assert_equal('Fossil', racer.hometown, 'Racer hometown')
    
    racer.city = nil
    racer.state = 'NY'
    assert_equal('NY', racer.hometown, 'Racer hometown')
    
    racer.city = 'Petaluma'
    racer.state = 'CA'
    assert_equal('Petaluma, CA', racer.hometown, 'Racer hometown')
    
    racer = Racer.new
    assert_equal(nil, racer.city, 'New Racer city')
    assert_equal(nil, racer.state, 'New Racer state')
    racer.hometown = ''
    assert_equal(nil, racer.city, 'New Racer city')
    assert_equal(nil, racer.state, 'New Racer state')
    racer.hometown = nil
    assert_equal(nil, racer.city, 'New Racer city')
    assert_equal(nil, racer.state, 'New Racer state')
    
    racer.hometown = 'Newport'
    assert_equal('Newport', racer.city, 'New Racer city')
    assert_equal(nil, racer.state, 'New Racer state')
    
    racer.hometown = 'Newport, RI'
    assert_equal('Newport', racer.city, 'New Racer city')
    assert_equal('RI', racer.state, 'New Racer state')
    
    racer.hometown = nil
    assert_equal(nil, racer.city, 'New Racer city')
    assert_equal(nil, racer.state, 'New Racer state')
    
    racer.hometown = ''
    assert_equal(nil, racer.city, 'New Racer city')
    assert_equal(nil, racer.state, 'New Racer state')
    
    racer.hometown = 'Newport, RI'
    racer.hometown = ''
    assert_equal(nil, racer.city, 'New Racer city')
    assert_equal(nil, racer.state, 'New Racer state')
  end

  def test_create_and_override_alias
    assert_not_nil(Racer.find_by_name('Molly Cameron'), 'Molly Cameron should exist')
    assert_not_nil(Alias.find_by_name('Mollie Cameron'), 'Mollie Cameron alias should exist')
    assert_nil(Racer.find_by_name('Mollie Cameron'), 'Mollie Cameron should not exist')

    dupe = Racer.create!(:name => 'Mollie Cameron')
    assert(dupe.valid?, 'Dupe Mollie Cameron should be valid')
    
    assert_not_nil(Racer.find_by_name('Molly Cameron'), 'Molly Cameron should exist')
    assert_not_nil(Racer.find_by_name('Mollie Cameron'), 'Ryan Weaver should exist')
    assert_nil(Alias.find_by_name('Molly Cameron'), 'Molly Cameron alias should not exist')
    assert_nil(Alias.find_by_name('Mollie Cameron'), 'Mollie Cameron alias should not exist')
  end
  
  def test_update_to_alias
    assert_not_nil(Racer.find_by_name('Molly Cameron'), 'Molly Cameron should exist')
    assert_not_nil(Alias.find_by_name('Mollie Cameron'), 'Mollie Cameron alias should exist')
    assert_nil(Racer.find_by_name('Mollie Cameron'), 'Mollie Cameron should not exist')

    molly = racers(:molly)
    molly.name = 'Mollie Cameron'
    molly.save!
    assert(molly.valid?, 'Renamed Mollie Cameron should be valid')
    
    assert_not_nil(Racer.find_by_name('Mollie Cameron'), 'Mollie Cameron should exist')
    assert_nil(Racer.find_by_name('Molly Cameron'), 'Molly Cameron should not exist')
    assert_nil(Alias.find_by_name('Mollie Cameron'), 'Mollie Cameron alias should not exist')
    assert_not_nil(Alias.find_by_name('Molly Cameron'), 'Molly Cameron alias should exist')
  end
  
  def test_sort
    r1 = Racer.new
    r1.id = 1
    r2 = Racer.new
    r2.id = 2
    r3 = Racer.new
    r3.id = 3
    
    racers = [r2, r1, r3]
    racers.sort!
    
    assert_equal([r1, r2, r3], racers, 'sorted')
  end
  
  def test_find_all_current_email_addresses
    email = Racer.find_all_current_email_addresses
    expected = [
      "Mark Matson <mcfatson@gentlelovers.com>",
      "Ryan Weaver <hotwheels@yahoo.com>"
    ]
    assert_equal(expected, email, "email addresses")
  end
  
  def test_add_number
    racer = Racer.create!
    racer.add_number("7890", nil)
    assert_equal("7890", racer.road_number, "Road number after add with nil discipline")    
  end
  
  def test_add_number_from_non_number_discipline
    racer = Racer.create!
    circuit_race = Discipline[:circuit]
    racer.add_number("7890", circuit_race)
    assert_equal("7890", racer.road_number, "Road number after add with nil discipline")
    assert_equal(nil, racer.number(circuit_race), "Circuit race number after add with nil discipline")
  end
end