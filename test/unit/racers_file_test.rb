require File.dirname(__FILE__) + '/../test_helper'

class RacerFileTest < Test::Unit::TestCase  
  def test_import
    tonkin = Racer.find(1)
    tonkin.member=(false)
    tonkin.ccx_category = 'A'
    tonkin.notes = 'Spent Christmans in Belgium'
    tonkin.save!

    file = File.new("#{File.dirname(__FILE__)}/../fixtures/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv")
    racers = RacersFile.new(file).import
    
    assert_equal([4, 1], racers, 'Number of racers created and updated')
    
    assert_equal(1, Racer.find_all_by_name('Erik Tonkin').size, 'Erik Tonkins in database after import')
    tonkin.reload
    assert_equal('Erik Tonkin', tonkin.name, 'Tonkin name')
    assert_equal_dates('1973-05-07', tonkin.date_of_birth, 'Birth date')
    assert_equal('F', tonkin.gender, 'gender')
    assert_equal('Judy@alum.dartmouth.org', tonkin.email, 'email')
    assert_equal("6272 Crest Ct. E.#{$INPUT_RECORD_SEPARATOR}Apt. 45", tonkin.street)
    assert_equal('Wenatchee', tonkin.city, 'city')
    assert_equal('WA', tonkin.state, 'state')
    assert_equal('97058', tonkin.zip, 'ZIP')
    assert_equal('541-296-9911', tonkin.home_phone, 'home_phone')
    assert_equal('IV Senior', tonkin.road_category, 'Road cat')
    assert_equal(nil, tonkin.track_category, 'track cat')
    assert_equal('A', tonkin.ccx_category, 'Cross cat')
    assert_equal('Expert Junior', tonkin.mtb_category, 'MTB cat')
    assert_equal('Physician', tonkin.occupation, 'occupation')
    assert_equal('Sorella Forte', tonkin.team_name, 'Team')
    notes = %Q{Spent Christmans in Belgium
Receipt Code: 2R2T6R7
Confirmation Code: 462TLJ7
Transaction Payment Total: 32.95
Registration Completion Date/Time: 11/20/06 10:04 AM
Disciplines: Road/Track/Cyclocross
Donation: 10
Downhill/Cross Country: Downhill}
    assert_equal(notes, tonkin.notes, 'notes')

    sautter = Racer.find_all_by_name('C Sautter').first
    assert_equal('C Sautter', sautter.name, 'Sautter name')
    assert_equal_dates('1966-01-06', sautter.date_of_birth, 'Birth date')
    assert_equal('M', sautter.gender, 'gender')
    assert_equal('Cr@comcast.net', sautter.email, 'email')
    assert_equal('262 SW 4th Ave', sautter.street)
    assert_equal('lake oswego', sautter.city, 'city')
    assert_equal('OR', sautter.state, 'state')
    assert_equal('97219', sautter.zip, 'ZIP')
    assert_equal('503-671-5743', sautter.home_phone, 'phone')
    assert_equal('IV Master', sautter.road_category, 'Road cat')
    assert_equal('IV Master', sautter.track_category, 'track cat')
    assert_equal('A Master', sautter.ccx_category, 'Cross cat')
    assert_equal('Sport Master 40+', sautter.mtb_category, 'MTB cat')
    assert_equal('Engineer', sautter.occupation, 'occupation')
    assert_equal('B.I.K.E. Hincapie', sautter.team_name, 'Team')
    notes = %Q{Spent Christmans in Belgium
Receipt Code: 2R2T6R7
Confirmation Code: 462TLJ7
Transaction Payment Total: 32.95
Registration Completion Date/Time: 11/20/06 10:04 AM
Disciplines: Road/Track/Cyclocross
Donation: 10
Downhill/Cross Country: Downhill}
    assert_equal(notes, tonkin.notes, 'notes')
    
    ted_gresham = Racer.find_all_by_name('Ted Greshsam').first
    assert_equal(nil, ted_gresham.team, 'Team')
    
    camden_murray = Racer.find_all_by_name('Camden Murray').first
    assert_equal(nil, camden_murray.team, 'Team')
  end
  
  def test_excel_file_database
    # Pre-existing racers
    Racer.create(
      :last_name =>'Abers',
      :first_name => 'Brian',
      :gender => 'M',
      :email =>'brian@sportslabtraining.com',
      :member_from => '2004-02-23',
      :date_of_birth => '1965-10-02',
      :notes => 'Existing notes'
    )

    Racer.create(
      :last_name =>'Babi',
      :first_name => 'Rene',
      :gender => 'M',
      :email =>'rbabi@rbaintl.com',
      :member_from => '2000-01-01',
      :team_name => 'RBA Cycling Team',
      :road_category => '4',
      :date_of_birth => '1899-07-14'
    )

    file = File.new("#{File.dirname(__FILE__)}/../fixtures/membership/database.xls")
    racers = RacersFile.new(file).import
    
    assert_equal([1, 2], racers, 'Number of racers created and updated')
    
    all_abers = Racer.find_all_by_name('Brian Abers')
    assert_equal(1, all_abers.size, 'Brian Abers in database after import')
    brian_abers = all_abers.first
    assert_equal('M', brian_abers.gender, 'Brian Abers gender')
    assert_equal('thekilomonster@verizon.net', brian_abers.email, 'Brian Abers email')
    assert_equal_dates('2007-01-16', brian_abers.member_from, 'Brian Abers member from')
    assert_equal_dates(Date.new(Date.today.year, 12, 31), brian_abers.member_to, 'Brian Abers member to')
    assert_equal_dates('1965-10-02', brian_abers.date_of_birth, 'Birth date')
    assert_equal("Existing notes\nr\ninterests: 1247", brian_abers.notes, 'Brian Abers notes')
    assert_equal('5735 SW 198th Ave', brian_abers.street, 'Brian Abers street')
    
    all_heidi_babi = Racer.find_all_by_name('heidi babi')
    assert_equal(1, all_heidi_babi.size, 'Heidi Babi in database after import')
    heidi_babi = all_heidi_babi.first
    assert_equal('F', heidi_babi.gender, 'Heidi Babi gender')
    assert_equal('hbabi77@hotmail.com', heidi_babi.email, 'Heidi Babi email')
    assert_equal_dates(Date.today, heidi_babi.member_from, 'Heidi Babi member from')
    assert_equal_dates(Date.new(Date.today.year, 12, 31), heidi_babi.member_to, 'Heidi Babi member to')
    assert_equal_dates('1977-01-01', heidi_babi.date_of_birth, 'Birth date')
    assert_equal("interests: 134", heidi_babi.notes, 'Heidi Babi notes')
    assert_equal('11408 NE 102ND ST', heidi_babi.street, 'Heidi Babi street')
    
    all_rene_babi = Racer.find_all_by_name('rene babi')
    assert_equal(1, all_rene_babi.size, 'Rene Babi in database after import')
    rene_babi = all_rene_babi.first
    assert_equal('M', rene_babi.gender, 'Rene Babi gender')
    assert_equal('rbabi@rbaintl.com', rene_babi.email, 'Rene Babi email')
    assert_equal_dates('2000-01-01', rene_babi.member_from, 'Rene Babi member from')
    assert_equal_dates(Date.new(Date.today.year, 12, 31), rene_babi.member_to, 'Rene Babi member to')
    assert_equal_dates('1899-07-14', rene_babi.date_of_birth, 'Birth date')
    assert_equal(nil, rene_babi.notes, 'Rene Babi notes')
    assert_equal('1431 SE Columbia Way', rene_babi.street, 'Rene Babi street')
  end
end