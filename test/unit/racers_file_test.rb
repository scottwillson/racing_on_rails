require File.dirname(__FILE__) + '/../test_helper'

class RacerFileTest < Test::Unit::TestCase  
  def test_import
    tonkin = Racer.find(1)
    tonkin.member=(false)
    tonkin.ccx_category = 'A'
    tonkin.notes = 'Spent Christmans in Belgium'
    tonkin.save!

    file = File.new("#{File.dirname(__FILE__)}/../fixtures/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv")
    racers = RacersFile.new(
      file,
      :delimiter => ',',
      :quoted => true,
      :header_row => true,
      :row_class => Racer,
      :column_map => {
        'Birth date' => 'date_of_birth',
        'Address1_Contact address' => 'street',
        'Address2_Contact address' => 'street',
        'Road Category -' => 'road_category',
        'track_category_' => 'track_category'
      }
    ).import
    
    assert_equal(5, racers, 'Number of racers imported')
    
    tonkin.reload
    assert_equal('Erik Tonkin', tonkin.name, 'Tonkin name')
#     assert_equal('05/07/73', tonkin.date_of_birth, 'Birth date')
#     assert_equal('F', tonkin.gender, 'gender')
#     assert_equal('judy.richardson.dms01@alum.dartmouth.org', tonkin.email, 'email')
#     assert_equal('6272 Crest Ct. E. Apt. 45', tonkin.street)
#     assert_equal('Wenatchee', tonkin.city, 'city')
#     assert_equal('WA', tonkin.state, 'state')
#     assert_equal('97058', tonkin.zip, 'ZIP')
#     assert_equal('541-296-9911', tonkin.phone, 'phone')
#     assert_equal('IV', tonkin.road_category, 'Road cat')
#     assert_equal('', tonkin.track_category, 'track cat')
#     assert_equal('A', tonkin.cx_category, 'Cross cat')
#     assert_equal('Expert Junior', tonkin.xc_category, 'MTB cat')
#     assert_equal('Physician', tonkin.occupation, 'occupation')
#     assert_equal('Sorella Forte', tonkin.team_name, 'Team')
#     notes = %Q{Spent Christmans in Belgium
# Receipt Code: 2R2T6R7
# Confirmation Code: 462TLJ7
# Transaction Payment Total: 32.95
# Registration Completion Date/Time: 11/20/06 10:04 AM
# Disciplines: Road/Track/Cyclocross
# Donation: 10
# Downhill/Cross counrty: Downhill
# Singlespeed: No
# Tandem}
#     assert_equal(notes, tonkin.notes, 'notes')
# 
#     sautter = Racer.find_all_by_name('C Sautter').first
#     assert_equal('C Sautter', tonkin.sautter, 'Sautter name')
#     assert_equal('05/07/73', tonkin.date_of_birth, 'Birth date')
#     assert_equal('F', tonkin.gender, 'gender')
#     assert_equal('judy.richardson.dms01@alum.dartmouth.org', tonkin.email, 'email')
#     assert_equal('6272 Crest Ct. E. Apt. 45', tonkin.street)
#     assert_equal('Wenatchee', tonkin.city, 'city')
#     assert_equal('WA', tonkin.state, 'state')
#     assert_equal('97058', tonkin.zip, 'ZIP')
#     assert_equal('541-296-9911', tonkin.phone, 'phone')
#     assert_equal('IV', tonkin.road_category, 'Road cat')
#     assert_equal('', tonkin.track_category, 'track cat')
#     assert_equal('A', tonkin.cx_category, 'Cross cat')
#     assert_equal('Expert Junior', tonkin.xc_category, 'MTB cat')
#     assert_equal('Physician', tonkin.occupation, 'occupation')
#     assert_equal('Sorella Forte', tonkin.team_name, 'Team')
#     notes = %Q{Spent Christmans in Belgium
# Receipt Code: 2R2T6R7
# Confirmation Code: 462TLJ7
# Transaction Payment Total: 32.95
# Registration Completion Date/Time: 11/20/06 10:04 AM
# Disciplines: Road/Track/Cyclocross
# Donation: 10
# Downhill/Cross counrty: Downhill
# Singlespeed: No
# Tandem}
#     assert_equal(notes, tonkin.notes, 'notes')
    # consolidated fields into notes
    # existing racer
    # - update #
    # - update membership
    # - update contact info
    # New racer
  end
end