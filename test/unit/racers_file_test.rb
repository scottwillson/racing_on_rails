require File.dirname(__FILE__) + '/../test_helper'

class RacerFileTest < Test::Unit::TestCase  
  def test_import
    tonkin = Racer.find(1)
    tonkin.member=(false)
    tonkin.ccx_category = 'A'
    tonkin.notes = 'Spent Christmans in Belgium'
    tonkin.save!

    file = File.new("#{File.dirname(__FILE__)}/../fixtures/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv")
    racers = RacersFile.new(file).import(true)
    
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
    assert_equal('Kona', tonkin.team_name, 'Team')
    notes = %Q{Spent Christmans in Belgium
Receipt Code: 2R2T6R7
Confirmation Code: 462TLJ7
Transaction Payment Total: 32.95
Registration Completion Date/Time: 11/20/06 10:04 AM
Disciplines: Road/Track/Cyclocross
Donation: 10
Downhill/Cross Country: Downhill}
    assert_equal(notes, tonkin.notes, 'notes')
    assert(tonkin.print_card?, 'Tonkin.print_card? after import')
    assert(tonkin.print_mailing_label?, 'Tonkin.mailing_label? after import')

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
    notes = %Q{Receipt Code: 922T4R7\nConfirmation Code: PQ2THJ7\nTransaction Payment Total: 22.3\nRegistration Completion Date/Time: 11/20/06 09:23 PM\nDisciplines: Road/Track/Cyclocross & Mtn Bike \nDonation: 0\nDownhill/Cross Country: Cross country\nSinglespeed: No\nOther interests: Marathon XC Short track XC}
    assert_equal(notes, sautter.notes, 'notes')
    assert(sautter.print_card?, 'sautter.print_card? after import')
    assert(sautter.print_mailing_label?, 'sautter.mailing_label? after import')
    
    ted_gresham = Racer.find_all_by_name('Ted Greshsam').first
    assert_equal(nil, ted_gresham.team, 'Team')
    
    camden_murray = Racer.find_all_by_name('Camden Murray').first
    assert_equal(nil, camden_murray.team, 'Team')
  end
  
  def test_excel_file_database
    # Pre-existing racers
    brian = Racer.create(
      :last_name =>'Abers',
      :first_name => 'Brian',
      :gender => 'M',
      :email =>'brian@sportslabtraining.com',
      :member_from => '2004-02-23',
      :member_to => Date.new(Date.today.year + 1, 12, 31),
      :date_of_birth => '1965-10-02',
      :notes => 'Existing notes'
    )
    assert(brian.valid?, brian.errors.full_messages)

    rene = Racer.create(
      :last_name =>'Babi',
      :first_name => 'Rene',
      :gender => 'M',
      :email =>'rbabi@rbaintl.com',
      :member_from => '2000-01-01',
      :team_name => 'RBA Cycling Team',
      :road_category => '4',
      :road_number => '190A',
      :date_of_birth => '1899-07-14'
    )
    assert(rene.valid?, rene.errors.full_messages)
    rene.reload
    assert_equal('190A', rene.road_number(true), 'Rene existing DH number')
    
    scott = Racer.create(
      :last_name =>'Seaton',
      :first_name => 'Scott',
      :gender => 'M',
      :email =>'sseaton@bendcable.com',
      :member_from => '2000-01-01',
      :team_name => 'EWEB',
      :road_category => '3',
      :date_of_birth => '1959-12-09'
    )
    assert(scott.valid?, scott.errors.full_messages)
    assert(!scott.new_record?)
    number = scott.race_numbers.create(:value => '422', :year => Date.today.year - 1)
    assert(number.valid?, number.errors.full_messages)
    assert(!number.new_record?, 'Number should be saved')
    number = RaceNumber.find(:first, :conditions => ['racer_id=? and value=?', scott.id, '422'])
    assert_not_nil(number, "Scott\'s previous road number")
    assert_equal(Discipline[:road], number.discipline, 'Discipline')
			
    file = File.new("#{File.dirname(__FILE__)}/../fixtures/membership/database.xls")
    racers = RacersFile.new(file).import(true)
    
    assert_equal([2, 3], racers, 'Number of racers created and updated')
    
    all_quinn_jackson = Racer.find_all_by_name('quinn jackson')
    assert_equal(1, all_quinn_jackson.size, 'Quinn Jackson in database after import')
    quinn_jackson = all_quinn_jackson.first
    assert_equal('M', quinn_jackson.gender, 'Quinn Jackson gender')
    assert_equal('quinn3769@yahoo.com', quinn_jackson.email, 'Quinn Jackson email')
    assert_equal_dates('2006-04-19', quinn_jackson.member_from, 'Quinn Jackson member from')
    assert_equal_dates(Date.new(Date.today.year, 12, 31), quinn_jackson.member_to, 'Quinn Jackson member to')
    assert_equal_dates('1969-01-01', quinn_jackson.date_of_birth, 'Birth date')
    assert_equal('interests: 14', quinn_jackson.notes, 'Quinn Jackson notes')
    assert_equal('1416 SW Hume Street', quinn_jackson.street, 'Quinn Jackson street')
    assert_equal('Portland', quinn_jackson.city, 'Quinn Jackson city')
    assert_equal('OR', quinn_jackson.state, 'Quinn Jackson state')
    assert_equal('97219', quinn_jackson.zip, 'Quinn Jackson ZIP')
    assert_equal('503-768-3822', quinn_jackson.home_phone, 'Quinn Jackson phone')
    assert_equal('nurse', quinn_jackson.occupation, 'Quinn Jackson occupation')
    assert_equal('120', quinn_jackson.xc_number(true), 'quinn_jackson xc number')
    assert(!quinn_jackson.print_card?, 'quinn_jackson.print_card? after import')
    assert(!quinn_jackson.print_mailing_label?, 'quinn_jackson.mailing_label? after import')
    
    all_abers = Racer.find_all_by_name('Brian Abers')
    assert_equal(1, all_abers.size, 'Brian Abers in database after import')
    brian_abers = all_abers.first
    assert_equal('M', brian_abers.gender, 'Brian Abers gender')
    assert_equal('thekilomonster@verizon.net', brian_abers.email, 'Brian Abers email')
    assert_equal_dates('2004-02-23', brian_abers.member_from, 'Brian Abers member from')
    assert_equal_dates(Date.new(Date.today.year, 12, 31), brian_abers.member_to, 'Brian Abers member to')
    assert_equal_dates('1965-10-02', brian_abers.date_of_birth, 'Birth date')
    assert_equal("Existing notes\nr\ninterests: 1247", brian_abers.notes, 'Brian Abers notes')
    assert_equal('5735 SW 198th Ave', brian_abers.street, 'Brian Abers street')
    assert_equal('825', brian_abers.road_number, 'Brian Abers road_number')
    assert(!brian_abers.print_card?, 'sautter.print_card? after import')
    assert(!brian_abers.print_mailing_label?, 'sautter.mailing_label? after import')
    
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
    assert_equal('360-896-3827', heidi_babi.home_phone, 'Heidi home phone')
    assert_equal('360-696-9272', heidi_babi.work_phone, 'Heidi work phone')
    assert_equal('360-696-9398', heidi_babi.cell_fax, 'Heidi cell/fax')
    assert(heidi_babi.print_card?, 'heidi_babi.print_card? after import')
    assert(heidi_babi.print_mailing_label?, 'heidi_babi.mailing_label? after import')
    
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
    assert(rene_babi.print_card?, 'rene_babi.print_card? after import')
    assert(rene_babi.print_mailing_label?, 'rene_babi.mailing_label? after import')
    assert_equal('190A', rene_babi.road_number, 'Rene road_number')
    
    all_scott_seaton = Racer.find_all_by_name('scott seaton')
    assert_equal(1, all_scott_seaton.size, 'Scott Seaton in database after import')
    scott_seaton = all_scott_seaton.first
    assert_equal('M', scott_seaton.gender, 'Scott Seaton gender')
    assert_equal('sseaton@bendcable.com', scott_seaton.email, 'Scott Seaton email')
    assert_equal_dates('2000-01-01', scott_seaton.member_from, 'Scott Seaton member from')
    assert_equal_dates(Date.new(Date.today.year, 12, 31), scott_seaton.member_to, 'Scott Seaton member to')
    assert_equal_dates('1959-12-09', scott_seaton.date_of_birth, 'Birth date')
    assert_equal('interests: 3146', scott_seaton.notes, 'Scott Seaton notes')
    assert_equal('1654 NW 2nd', scott_seaton.street, 'Scott Seaton street')
    assert_equal('Bend', scott_seaton.city, 'Scott Seaton city')
    assert_equal('OR', scott_seaton.state, 'Scott Seaton state')
    assert_equal('97701', scott_seaton.zip, 'Scott Seaton ZIP')
    assert_equal('541-389-3721', scott_seaton.home_phone, 'Scott Seaton phone')
    assert_equal('firefighter', scott_seaton.occupation, 'Scott Seaton occupation')
    assert_equal('EWEB', scott_seaton.team_name, 'Scott Seaton team should be updated')
    assert(!scott_seaton.print_card?, 'sautter.print_card? after import')
    assert(!scott_seaton.print_mailing_label?, 'sautter.mailing_label? after import')
    
    scott.race_numbers.create(:value => '422', :year => Date.today.year - 1)
    number = RaceNumber.find(:first, :conditions => ['racer_id=? and value=?', scott.id, '422'])
    assert_not_nil(number, "Scott\'s previous road number")
    assert_equal(Discipline[:road], number.discipline, 'Discipline')
  end
  
  def test_import_duplicates
    Racer.create(:name => 'Erik Tonkin')
    file = File.new("#{File.dirname(__FILE__)}/../fixtures/membership/duplicates.xls")
    racers_file = RacersFile.new(file)
    racers_file.import(true)
    
    assert_equal(1, racers_file.created, 'Number of racers created')
    assert_equal(0, racers_file.updated, 'Number of racers updated')
    assert_equal(1, racers_file.duplicates.size, 'Number of duplicates')
    
    # Assert data
    # Add dupe with number and assert matching
  end
end