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
Downhill/Cross Country: Downhill
Singlespeed: 
Other interests: }
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
Downhill/Cross Country: Downhill
Singlespeed: 
Other interests: }
    assert_equal(notes, tonkin.notes, 'notes')
    # consolidated fields into notes
    # existing racer
    # - update #
    # - update membership
    # - update contact info
    # New racer
    # N/A = No team
    # How to handle more than one existing racer with same name?
  end
end