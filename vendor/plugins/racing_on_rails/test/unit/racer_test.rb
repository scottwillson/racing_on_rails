require File.dirname(__FILE__) + '/../test_helper'

class RacerTest < Test::Unit::TestCase

  fixtures :teams, :racers, :aliases

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
    racer = Racer.new(
      :date_of_birth => '1970-12-31',
      :cell_fax => '(315) 342-1313',
      :city => "Santa Rosa", 
      :ccx_category => 'A', 
      :dh_category => 'Novice', 
      :dh_number => "98", 
      :email => 'andy@pig_bikes.com',
      :first_name => 'Andy',
      :gender => 'M',
      :home_phone => '(315) 221-4774',
      :last_name => "Hampsten", 
      :license => "125162", 
      :mtb_category => 'Expert', 
      :notes => 'Won Giro', 
      :member_on => '2001-07-19', 
      :road_number => "300", 
      :occupation => 'Vinter', 
      :road_category => '1', 
      :state => "CA", 
      :street => "5 Burr Street", 
      :team => {:name => "7-11"},
      :track_category => '2', 
      :work_phone => '(315) 444-1022',
      :xc_number => "100",
      :zip => "13035"
    )
    assert_equal_dates("1970-12-31", racer.date_of_birth, "date_of_birth")
    assert_equal("(315) 342-1313", racer.cell_fax, "cell_fax")
    assert_equal("A", racer.ccx_category, "ccx_category")
    assert_equal("Novice", racer.dh_category, "dh_category")
    assert_equal("(315) 221-4774", racer.home_phone, "home_phone")
    assert_equal("Expert", racer.mtb_category, "mtb_category")
    assert_equal_dates("2001-07-19", racer.member_on, "member_on")
    assert_equal("Vinter", racer.occupation, "occupation")
    assert_equal("1", racer.road_category, "road_category")
    assert_equal("2", racer.track_category, "track_category")
    assert_equal("100", racer.xc_number, "xc_number")
    assert_equal("Santa Rosa", racer.city, "city")
    assert_equal("98", racer.dh_number, "dh_number")
    assert_equal("andy@pig_bikes.com", racer.email, "email")
    assert_equal("M", racer.gender, "gender")
    assert_equal("125162", racer.license, "license")
    assert_equal("Andy Hampsten", racer.name, "name")
    assert_equal("Won Giro", racer.notes, "notes")
    assert_equal("300", racer.road_number, "road_number")
    assert_equal("CA", racer.state, "state")
    assert_equal("5 Burr Street", racer.street, "street")
    assert_equal("7-11", racer.team.name, "team.name")
    assert_equal("100", racer.xc_number, "xc_number")
    assert_equal("13035", racer.zip, "xc_number")
    
    racer.save!
    racer.reload
    
    assert_equal_dates("1970-12-31", racer.date_of_birth, "date_of_birth")
    assert_equal("(315) 342-1313", racer.cell_fax, "cell_fax")
    assert_equal("A", racer.ccx_category, "ccx_category")
    assert_equal("Novice", racer.dh_category, "dh_category")
    assert_equal("(315) 221-4774", racer.home_phone, "home_phone")
    assert_equal("Expert", racer.mtb_category, "mtb_category")
    assert_equal_dates("2001-07-19", racer.member_on, "member_on")
    assert_equal("Vinter", racer.occupation, "occupation")
    assert_equal("1", racer.road_category, "road_category")
    assert_equal("2", racer.track_category, "track_category")
    assert_equal("100", racer.xc_number, "xc_number")
    assert_equal("Santa Rosa", racer.city, "city")
    assert_equal("98", racer.dh_number, "dh_number")
    assert_equal("andy@pig_bikes.com", racer.email, "email")
    assert_equal("M", racer.gender, "gender")
    assert_equal("125162", racer.license, "license")
    assert_equal("Andy Hampsten", racer.name, "name")
    assert_equal("Won Giro", racer.notes, "notes")
    assert_equal("300", racer.road_number, "road_number")
    assert_equal("CA", racer.state, "state")
    assert_equal("5 Burr Street", racer.street, "street")
    assert_equal("7-11", racer.team.name, "team.name")
    assert_equal("100", racer.xc_number, "xc_number")
    assert_equal("13035", racer.zip, "xc_number")
  end
  
  def test_merge
    racer_to_keep = racers(:mollie)
    racer_to_merge = racers(:tonkin)
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_keep.first_name, racer_to_keep.last_name), "#{racer_to_keep.name} should be in DB")
    # assert_equal(3, Result.find_all_by_racer_id(racer_to_keep.id).size, "Mollie's results")
    assert_equal(1, Alias.find_all_by_racer_id(racer_to_keep.id).size, "Mollies's aliases")
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_merge.first_name, racer_to_merge.last_name), "#{racer_to_merge.name} should be in DB")
    # assert_equal(2, Result.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's results")
    assert_equal(1, Alias.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's aliases")
    
    racer_to_keep.merge(racer_to_merge)
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_keep.first_name, racer_to_keep.last_name), "#{racer_to_keep.name} should be in DB")
    # assert_equal(5, Result.find_all_by_racer_id(racer_to_keep.id).size, "Mollie's results")
    aliases = Alias.find_all_by_racer_id(racer_to_keep.id)
    erik_alias = aliases.detect{|a| a.name == 'Erik Tonkin'}
    assert_not_nil(erik_alias, 'Mollie should have Erik Tonkin alias')
    assert_equal(3, Alias.find_all_by_racer_id(racer_to_keep.id).size, "Mollie's aliases")
    
    assert_nil(Racer.find_by_first_name_and_last_name(racer_to_merge.first_name, racer_to_merge.last_name), "#{racer_to_merge.name} should not be in DB")
    # assert_equal(0, Result.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's results")
    assert_equal(0, Alias.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's aliases")
  end
  
  def test_merge_no_alias_dup_names
    racer_to_keep = racers(:mollie)
    racer_to_merge = racers(:tonkin)
    racer_same_name_as_merged = Racer.create(:name => racer_to_merge.name, :road_number => 'YYZ')
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_keep.first_name, racer_to_keep.last_name), "#{racer_to_keep.name} should be in DB")
    # assert_equal(3, Result.find_all_by_racer_id(racer_to_keep.id).size, "Mollie's results")
    assert_equal(1, Alias.find_all_by_racer_id(racer_to_keep.id).size, "Mollies's aliases")
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_merge.first_name, racer_to_merge.last_name), "#{racer_to_merge.name} should be in DB")
    # assert_equal(2, Result.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's results")
    assert_equal(1, Alias.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's aliases")
    
    racer_to_keep.merge(racer_to_merge)
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_keep.first_name, racer_to_keep.last_name), "#{racer_to_keep.name} should be in DB")
    # assert_equal(5, Result.find_all_by_racer_id(racer_to_keep.id).size, "Mollie's results")
    aliases = Alias.find_all_by_racer_id(racer_to_keep.id)
    erik_alias = aliases.detect{|a| a.name == 'Erik Tonkin'}
    assert_nil(erik_alias, 'Mollie should not have Erik Tonkin alias because there is another Erik Tonkin')
    assert_equal(2, Alias.find_all_by_racer_id(racer_to_keep.id).size, "Mollie's aliases")
    
    assert_not_nil(Racer.find_by_first_name_and_last_name(racer_to_merge.first_name, racer_to_merge.last_name), "#{racer_to_merge.name} should still be in DB")
    # assert_equal(0, Result.find_all_by_racer_id(racer_to_merge.id).size, "Tonkin's results")
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
    assert_equal(true, racer.member, 'member')
    racer.member = false
    assert_equal(false, racer.member, 'member')
    racer.save!
    racer.reload
    assert_equal(false, racer.member, 'member')

    racer.member = true
    racer.save!
    racer.reload
    assert_equal(true, racer.member, 'member')
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
  
  # Numbers should be unique
  def test_match
    # criteria: (first_name + last_name, last_name, name), number, team (12)
    # match: first_name + last_name, last_name, alias, number, team, team_alias (256)
    # existing: 0, 1, 2 (3)
    
    tonkin = racers(:tonkin)
    assert_equal([tonkin], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin'), 'first_name + last_name')
    assert_equal([tonkin], Racer.match(:last_name => 'Tonkin'), 'last_name')
    assert_equal([tonkin], Racer.match(:first_name => 'Erik'), 'first_name')
    assert_equal([tonkin], Racer.match(:name => 'erik tonkin'), 'name')

    assert_equal([], Racer.match(:first_name => 'Erika', :last_name => 'Tonkin'), 'first_name + last_name should not match')
    assert_equal([], Racer.match(:last_name => 'onkin'), 'last_name should not match')
    assert_equal([], Racer.match(:first_name => 'Erika'), 'first_name should not match')
    assert_equal([], Racer.match(:name => 'Erika Tonkin'), 'name should not match')

    assert_equal([tonkin], Racer.match(:road_number => '104'), 'road number')
    assert_equal([tonkin], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin', :road_number => '104'), 'road number, first_name, last_name')
    assert_equal([tonkin], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin', :ccx_number => '6'), 'cross number (not in DB), first_name, last_name')

    # TODO Add warning that numbers don't match
    assert_equal([tonkin], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin', :road_number => '1'), 'Different number')
    assert_equal([], Racer.match(:first_name => 'Rhonda', :last_name => 'Tonkin', :road_number => '104'), 'Different number')
    assert_equal([], Racer.match(:first_name => 'Erik', :last_name => 'Viking', :road_number => '104'), 'Different number')

    tonkin_clone = Racer.create(:first_name => 'Erik', :last_name => 'Tonkin', :road_number => '1')
    unless tonkin_clone.valid?
      flunk(tonkin_clone.errors.full_messages)
    end
    assert_same_elements([tonkin, tonkin_clone], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin'))
    assert_same_elements([tonkin, tonkin_clone], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin', :ccx_number => '6'))
    assert_same_elements([tonkin, tonkin_clone], Racer.match(:last_name => 'Tonkin'))
    assert_same_elements([tonkin, tonkin_clone], Racer.match(:first_name => 'Erik'))
    assert_same_elements([tonkin, tonkin_clone], Racer.match(:first_name => 'Erik'))
    assert_equal([], Racer.match(:ccx_number => '6'), 'ccx number (not in DB)')
    assert_equal([tonkin], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin', :road_number => '104'), 'road number, first_name, last_name')
    assert_equal([tonkin_clone], Racer.match(:road_number => '1'), 'road number')
    assert_equal([tonkin_clone], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin', :road_number => '1'), 'road number, first_name, last_name')
    
    # team_name -- consider last
    assert_equal([tonkin], Racer.match(:name => 'erik tonkin', :team_name => 'Kona'), 'name, team')
    assert_equal([], Racer.match(:first_name => 'Erika', :last_name => 'Tonkin', :team_name => 'Kona'), 'first_name + last_name should not match')
    assert_equal([tonkin], Racer.match(:name => 'erik tonkin', :team_name => 'Kona', :road_number => '104'), 'name, team, number, should match')
    assert_equal([tonkin], Racer.match(:last_name => 'Tonkin', :team_name => 'Kona'), 'last_name + team should match')
    assert_equal([tonkin_clone], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => ''), 'first_name, last_name + team should match')
    assert_equal([racers(:weaver)], Racer.match(:name => 'Ryan Weaver', :team_name => 'Camerati'), 'name + wrong team should match')
    assert_equal([racers(:weaver)], Racer.match(:name => 'Ryan Weaver', :team_name => 'Camerati', :road_number => '987'), 
                'name + wrong team + wrong number should match')
    tonkin_clone.team = teams(:vanilla)
    tonkin_clone.save!
    assert_equal([tonkin_clone], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Vanilla Bicycles'), 
                'first_name, last_name + team alias should match')
                
    # required: first, last, name, or number 
    assert_equal([], Racer.match({}), 'blank name should not match if no blank names in DB')
    assert_equal([], Racer.match(:team_name => 'Astana Wurth'), 'blank team name should not match if no blank names in DB')
    assert_raise(ArgumentError) {Racer.match({:first_name => 'Erik', :name => 'fred rogers'})}
    assert_raise(ArgumentError) {Racer.match({:last_name => 'Tonkin', :name => 'fred rogers'})}
    assert_raise(ArgumentError) {Racer.match({:first_name => 'Erik', :last_name => 'Tonkin', :name => 'fred rogers'})}
    
    # rental numbers
    assert_equal([tonkin, tonkin_clone], Racer.match(:first_name => 'Erik', :last_name => 'Tonkin', :road_number => '60'), 'road number, first_name, last_name')
    
    assert_equal([], Racer.match(:first_name => '', :last_name => ''), 'blank first_name + last_name should not match if no blank names in DB')
    assert_equal([], Racer.match(:name => ''), 'blank name should not match if no blank names in DB')
    
    blank_name_racer = Racer.create(:name => '', :dh_number => '1')
    assert_equal([blank_name_racer], Racer.match(:first_name => '', :last_name => ''), 'blank first_name + last_name should match')
    assert_equal([blank_name_racer], Racer.match(:name => ''), 'blank name should  match')
  end
  
  def test_duplicate
    Racer.create(:first_name => 'Otis', :last_name => 'Guy')
    racer = Racer.new(:first_name => 'Otis', :last_name => 'Guy')
    assert(!racer.valid?, 'Dupe racer name with no number should be invalid')

    racer = Racer.new(:first_name => 'Otis', :last_name => 'Guy', :road_number => '180')
    assert(!racer.valid?, 'Dupe racer name invalid if racer has no numbers')

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

    racer.date_of_birth = Date.new(60.years.ago.year, 12, 31)
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
end