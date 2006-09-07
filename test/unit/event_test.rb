require File.dirname(__FILE__) + '/../test_helper'

class EventTest < Test::Unit::TestCase
  
  def test_find_years
    years = Event.find_all_years
    assert_equal(3, years.size, "Should find 3 years")
    assert_equal([2005, 2004, 2003], years, "Years")
  end
  
  def test_load_associations
    event = Event.find(5)
    assert_nil(event.promoter, "event.promoter")
  
    event = Event.find(1)
    assert_not_nil(event.promoter, "event.promoter")
  
    event = Event.find(2)
    assert_not_nil(event.promoter, "event.promoter")
  
    event = Event.find(4)
    assert_not_nil(event.promoter, "event.promoter")
  end
  
  def test_new_defaults
    event = SingleDayEvent.new
    assert_equal(Date.today, event.date, "New event should have today's date")
    formatted_date = Date.today.strftime("%m-%d-%Y")
    assert_equal("New Event #{formatted_date}", event.name, "event name")
    assert_equal("OR", event.state, "event.state")
    assert_nil(event.discipline, "event.discipline")
    assert_equal("CBRA", event.sanctioned_by, "New event sanctioned_by default")
  end
  
  def test_new_with_promoters
    promoter_name = "Scout"
    assert_nil(Promoter.find_by_name(promoter_name), "Promoter #{promoter_name} should not be in DB")
    event = SingleDayEvent.new({
      :name => "Silverton",
      :promoter => {
        :name => promoter_name
      }
    })
    assert_not_nil(event.promoter, "Event promoter before save")
    event.save!
    assert_not_nil(event.promoter, "Event promoter after save")
    assert_equal(1, Promoter.count("name = '#{promoter_name}'"), "Promoter #{promoter_name} count in DB")

    event = SingleDayEvent.new({
      :name => "State Criterium",
      :promoter => {
        :name => promoter_name
      }
    })
    assert_not_nil(event.promoter, "Event promoter before save")
    event.save!
    assert_not_nil(event.promoter, "Event promoter after save")
    assert_equal(1, Promoter.count("name = '#{promoter_name}'"), "Promoter #{promoter_name} count in DB")
  end
  
  def test_new_add_promoter
    event = SingleDayEvent.new
    candi = promoters(:candi_murray)
    event.promoter = candi
    assert_equal(candi, event.promoter, "New event promoter before save")
    event.save!
    assert_equal(candi, event.promoter, "New event promoter after save")
    event.reload
    assert_equal(candi, event.promoter, "New event promoter after reload")

    # Only email and phone
    event = SingleDayEvent.new
    nate_hobson = promoters(:nate_hobson)
    nate_hobson.save!
    assert(nate_hobson.errors.empty?, "Errors: #{nate_hobson.errors.full_messages.join(', ')}")
    event.promoter = nate_hobson
    assert_equal(nate_hobson, event.promoter, "New event promoter before save")
    event.save!
    assert(nate_hobson.errors.empty?, "Errors: #{nate_hobson.errors.full_messages.join(', ')}")
    assert(event.errors.empty?, "Errors: #{event.errors.full_messages.join(', ')}")
    assert_equal(nate_hobson, event.promoter, "New event promoter after save")
    event.reload
    assert_equal(nate_hobson, event.promoter, "New event promoter after reload")

    event = SingleDayEvent.new
    nate_hobson = promoters(:nate_hobson)
    event.promoter = nate_hobson
    assert_equal(nate_hobson, event.promoter, "New event promoter before save")
    event.save!
    assert_equal(nate_hobson, event.promoter, "New event promoter after save")
    event.reload
    assert_equal(nate_hobson, event.promoter, "New event promoter after reload")
  end

  def test_timestamps
    hood_river_crit = SingleDayEvent.new(:name => "Hood River")
    hood_river_crit.save!
    hood_river_crit.reload
    assert_not_nil(hood_river_crit.created_at, "initial hood_river_crit.created_at")
    assert_not_nil(hood_river_crit.updated_at, "initial hood_river_crit.updated_at")
    assert_equal(hood_river_crit.created_at, hood_river_crit.updated_at, "initial hood_river_crit.updated_at and created_at")
    sleep(1)
    hood_river_crit.flyer = "http://foo_bar.org/"
    hood_river_crit.save!
    hood_river_crit.reload
    assert(
      hood_river_crit.created_at != hood_river_crit.updated_at, 
      "hood_river_crit.updated_at '#{hood_river_crit.updated_at}' and created_at '#{hood_river_crit.created_at}' different after update"
    )
  end
  
  def test_validation
    tabor_cr = events(:tabor_cr)
    tabor_cr.name = nil
    assert_raises(ActiveRecord::RecordInvalid) {tabor_cr.save!}
  end
  
  def test_destroy
    pir_july_2 = events(:pir)
    pir_july_2.destroy
    assert_raises(ActiveRecord::RecordNotFound, "PIR should be deleted") {Event.find(pir_july_2.id)}
  end
  
  def test_to_param
    tabor_cr = events(:tabor_cr)
    assert_equal(6, tabor_cr.to_param, "to_param")
  end
  
  def test_short_date
    event = Event.new

    event.date = Date.new(2006, 9, 9)
    assert_equal(' 9/9 ', event.short_date, 'Short date')    

    event.date = Date.new(2006, 9, 10)
    assert_equal(' 9/10', event.short_date, 'Short date')    

    event.date = Date.new(2006, 10, 9)
    assert_equal('10/9 ', event.short_date, 'Short date')    

    event.date = Date.new(2006, 10, 10)
    assert_equal('10/10', event.short_date, 'Short date')    
  end
  
  def test_cancelled
    pir_july_2 = events(:pir)
    assert(!pir_july_2.cancelled, 'cancelled')
    
    pir_july_2.cancelled = true
    pir_july_2.save!
    assert(pir_july_2.cancelled, 'cancelled')
  end
  
  def test_notes
    event = SingleDayEvent.create(:name => 'New Event')
    assert_equal('', event.notes, 'New notes')
    event.notes = 'My notes'
    event.save!
    event.reload
    assert_equal('My notes', event.notes)
  end
end