require "test_helper"

class EventTest < ActiveSupport::TestCase
    
  def test_create
    event = SingleDayEvent.create(:name => 'Saved')
    assert(event.races.empty?, "Races")
  end

  def test_find_years
    years = Event.find_all_years
    assert_equal(5, years.size, "Should find all years with events")
    assert_equal([Date.today.year, 2005, 2004, 2003, 2002], years, "Years")
  end
  
  def test_defaults
    event = SingleDayEvent.new
    assert_equal(Date.today, event.date, "New event should have today's date")
    formatted_date = Date.today.strftime("%m-%d-%Y")
    assert_equal("New Event #{formatted_date}", event.name, "event name")
    assert_equal(ASSOCIATION.state, event.state, "event.state")
    assert_equal("Road", event.discipline, "event.discipline")
    assert_equal(ASSOCIATION.short_name, event.sanctioned_by, "New event sanctioned_by default")
    number_issuer = NumberIssuer.find_by_name(ASSOCIATION.short_name)
    assert_equal(number_issuer, event.number_issuer, "New event number_issuer default")
  end
  
  def test_new_with_promoters
    promoter_name = "Scout"
    assert_nil(Promoter.find_by_name(promoter_name), "Promoter #{promoter_name} should not be in DB")
    event = SingleDayEvent.new({
      :name => "Silverton",
      :promoter => Promoter.new(:name => promoter_name)
    })
    assert_not_nil(event.promoter, "Event promoter before save")
    event.save!
    assert_not_nil(event.promoter, "Event promoter after save")
    assert_equal(1, Promoter.count(:conditions => "name = '#{promoter_name}'"), "Promoter #{promoter_name} count in DB")

    event = SingleDayEvent.new({
      :name => "State Criterium",
      :promoter => Promoter.new(:name => promoter_name)
    })
    assert_not_nil(event.promoter, "Event promoter before save")
    event.save!
    assert_not_nil(event.promoter, "Event promoter after save")
    assert_equal(1, Promoter.count(:conditions => "name = '#{promoter_name}'"), "Promoter #{promoter_name} count in DB")
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
  
  def test_set_promoter
    event = SingleDayEvent.new
    promoter = Promoter.new(:name => 'Toni Kic')
    event.promoter = promoter
    assert_not_nil(event.promoter, 'event.promoter')
    assert_equal('Toni Kic', event.promoter.name, 'event.promoter.name')
  end

  def test_timestamps
    hood_river_crit = SingleDayEvent.new(:name => "Hood River")
    hood_river_crit.save!
    hood_river_crit.reload
    assert_not_nil(hood_river_crit.created_at, "initial hood_river_crit.created_at")
    assert_not_nil(hood_river_crit.updated_at, "initial hood_river_crit.updated_at")
    assert_in_delta(hood_river_crit.created_at, hood_river_crit.updated_at, 1, "initial hood_river_crit.updated_at and created_at")
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
    event = SingleDayEvent.create!
    event.races.create!(:category => categories(:cat_3))
    event.destroy
    assert(!Event.exists?(event.id), "event should be deleted")
  end
  
  def test_no_delete_with_results
    kings_valley = events(:kings_valley)
    assert(!kings_valley.destroy, 'Should not be destroyed')
    assert(!kings_valley.errors.empty?, 'Should have errors')
    assert_not_nil(Event.find(kings_valley.id), "Kings Valley should not be deleted")
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
  
  def test_date_range_s_long
    mt_hood = events(:mt_hood)
    assert_equal("07/11/2005-07/12/2005", mt_hood.date_range_s(:long), "date_range_s(long)")
    mt_hood.children.last.date = Date.new(2005, 8, 1)
    mt_hood.children.last.save!
    mt_hood.save!
    mt_hood.reload
    assert_equal("07/11/2005-08/01/2005", mt_hood.date_range_s(:long), "date_range_s(long)")

    kings_valley = events(:kings_valley)
    assert_equal("12/31/2003", kings_valley.date_range_s(:long), "date_range_s(long)")
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
  
  def test_number_issuer
    kings_valley = events(:kings_valley_2004)
    assert_equal(number_issuers(:association), kings_valley.number_issuer, '2004 Kings Valley NumberIssuer')
  end
  
  def test_default_number_issuer
    event = SingleDayEvent.create!(:name => 'Unsanctioned')
    event.reload
    assert_equal(ASSOCIATION.short_name, event.sanctioned_by, 'sanctioned_by')
    assert_equal(number_issuers(:association), event.number_issuer(true), 'number_issuer')
  end
  
  def test_find_max_date_for_current_year
    Result.delete_all
    Event.delete_all
    assert_nil(Event.find_max_date_for_current_year)
    SingleDayEvent.create(:date => Date.new(Date.today.year, 6, 10))
    assert_equal_dates("#{Date.today.year}-06-10", Event.find_max_date_for_current_year)
  end
  
  def test_flyer
    event = SingleDayEvent.new
    assert_equal(nil, event.flyer, 'Blank event flyer')
    
    event.flyer = 'http://veloshop.org/pir.html'
    assert_equal('http://veloshop.org/pir.html', event.flyer, 'Other site flyer')
    
    event.flyer = '/events/pir.html'
    assert_equal("http://#{STATIC_HOST}/events/pir.html", event.flyer, 'Absolute root flyer')
    
    event.flyer = '../../events/pir.html'
    assert_equal("http://#{STATIC_HOST}/events/pir.html", event.flyer, 'Relative root flyer')
  end
  
  def test_sort
    jan_event = SingleDayEvent.new(:date => Date.new(1998, 1, 4))
    march_event = MultiDayEvent.new(:date => Date.new(1998, 3, 2))
    nov_event = Series.new(:date => Date.new(1998, 11, 20))
    events = [jan_event, march_event, nov_event]
    
    assert_equal([jan_event, march_event, nov_event], events.sort, 'Unsaved events should be sorted by date')
    march_event.date = Date.new(1999)
    assert_equal([jan_event, nov_event, march_event], events.sort, 'Unsaved events should be sorted by date')
    
    events.each {|e| e.save!}
    assert_equal([jan_event, nov_event, march_event], events.sort, 'Saved events should be sorted by date')
    march_event.date = Date.new(1998, 3, 2)
    assert_equal([jan_event, march_event, nov_event], events.sort, 'Saved events should be sorted by date')
  end
  
  def test_multi_day_event_children_with_no_parent
    event = SingleDayEvent.create!(:name => 'PIR')
    assert(!event.multi_day_event_children_with_no_parent?)
    assert(event.multi_day_event_children_with_no_parent.empty?)
    
    assert(!events(:kings_valley_2004).multi_day_event_children_with_no_parent?)
    assert(events(:kings_valley_2004).multi_day_event_children_with_no_parent.empty?)
    
    MultiDayEvent.create!(:name => 'PIR', :date => Date.new(Date.today.year, 9, 12))
    event = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(Date.today.year, 9, 12))
    assert(!(event.multi_day_event_children_with_no_parent?))
    assert(event.multi_day_event_children_with_no_parent.empty?)
      
    assert(!events(:banana_belt_series).multi_day_event_children_with_no_parent?)
    assert(!events(:banana_belt_1).multi_day_event_children_with_no_parent?)
    assert(!events(:banana_belt_2).multi_day_event_children_with_no_parent?)
    assert(!events(:banana_belt_3).multi_day_event_children_with_no_parent?)
      
    pir_1 = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(2009, 9, 5))
    assert(!pir_1.multi_day_event_children_with_no_parent?)
    assert(pir_1.multi_day_event_children_with_no_parent.empty?)
    pir_2 = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(2010, 9, 12))
    assert(!pir_1.multi_day_event_children_with_no_parent?)
    assert(!pir_2.multi_day_event_children_with_no_parent?)
    assert(pir_1.multi_day_event_children_with_no_parent.empty?)
    assert(pir_2.multi_day_event_children_with_no_parent.empty?)

    pir_3 = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(2010, 9, 17))
    # Need to completely reset state
    pir_1 = SingleDayEvent.find(pir_1.id)
    pir_2 = SingleDayEvent.find(pir_2.id)
    assert(!pir_1.multi_day_event_children_with_no_parent?)
    assert(pir_2.multi_day_event_children_with_no_parent?)
    assert(pir_3.multi_day_event_children_with_no_parent?)
    assert(pir_1.multi_day_event_children_with_no_parent.empty?)
    assert(!(pir_2.multi_day_event_children_with_no_parent.empty?))
    assert(!(pir_3.multi_day_event_children_with_no_parent.empty?))
    
    assert(!events(:mt_hood).multi_day_event_children_with_no_parent?)
    assert(!events(:mt_hood_1).multi_day_event_children_with_no_parent?)
    assert(!events(:mt_hood_2).multi_day_event_children_with_no_parent?)
  
    mt_hood_3 = SingleDayEvent.create(:name => 'Mt. Hood Classic', :date => Date.new(2005, 7, 13))
    assert(!events(:mt_hood).multi_day_event_children_with_no_parent?)
    assert(!events(:mt_hood_1).multi_day_event_children_with_no_parent?)
    assert(!events(:mt_hood_2).multi_day_event_children_with_no_parent?)
    assert(!(mt_hood_3.multi_day_event_children_with_no_parent?))
    assert(mt_hood_3.multi_day_event_children_with_no_parent.empty?)
  end

  def test_missing_children
    event = SingleDayEvent.create!(:name => 'PIR')
    assert_no_orphans(event)
    
    assert_no_orphans(events(:kings_valley_2004))
    
    SingleDayEvent.create!(:name => 'PIR', :date => Date.new(Date.today.year, 9, 12))
    event = MultiDayEvent.create!(:name => 'PIR')
    assert_orphans(2, event)
  
    assert_no_orphans(events(:banana_belt_series))
    assert_no_orphans(events(:banana_belt_1))
    assert_no_orphans(events(:banana_belt_2))
    assert_no_orphans(events(:banana_belt_3))
  
    pir_1 = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(2009, 9, 5))
    assert_no_orphans(pir_1)
    pir_2 = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(2010, 9, 12))
    assert_no_orphans(pir_1)
    assert_no_orphans(pir_2)
    
    assert_no_orphans(events(:mt_hood))
    assert_no_orphans(events(:mt_hood_1))
    assert_no_orphans(events(:mt_hood_2))
  
    mt_hood_3 = SingleDayEvent.create(:name => 'Mt. Hood Classic', :date => Date.new(2005, 7, 13))
    assert_no_orphans(events(:mt_hood))
    assert_no_orphans(events(:mt_hood_1))
    assert_no_orphans(events(:mt_hood_2))
    assert_no_orphans(mt_hood_3)
  end
  
  def test_has_results
    assert(!Event.new.has_results?, "New Event should not have results")
    
    event = SingleDayEvent.create!
    race = event.races.create!(:category => categories(:senior_men))
    assert(!event.has_results?, "Event with race, but no results should not have results")
    
    race.results.create!(:place => 200, :racer => racers(:matson))
    assert(event.has_results?, "Event with one result should not have results")
  end
  
  def test_inspect
    event = SingleDayEvent.create!
    event.races.create!(:category => categories(:senior_men)).results.create!(:place => 1)
    event.inspect
  end
  
  def test_location
    assert_equal(ASSOCIATION.state, SingleDayEvent.create!.location, "New event location")
    assert_equal("Canton, OH", SingleDayEvent.create!(:city => "Canton", :state => "OH").location, "City, state location")

    event = SingleDayEvent.create!(:city => "Vatican City")
    event.state = nil
    assert_equal("Vatican City", event.location, "City location")

    event = SingleDayEvent.create!
    event.state = nil
    assert_equal("", event.location, "No city, state location")
  end

  def test_combined_tt
    jack_frost = events(:jack_frost_2002)
    assert_equal(0, jack_frost.children.size, 'children.size')
    assert_equal(2, jack_frost.races.size, 'races')
    assert_equal(3, jack_frost.races.first.results.size + jack_frost.races.last.results.size, 'total number of results')
    
    jack_frost.create_or_destroy_combined_results
    combined_results = jack_frost.combined_results
    combined_results.calculate!
    
    assert_equal(false, combined_results.ironman, 'Ironman')
    
    assert_equal('Combined', combined_results.name, 'name')
    assert_equal(0, combined_results.bar_points, 'bar points')
    assert_equal(1, combined_results.races.size, 'combined_results.races')
    combined = combined_results.races.first
    assert_equal(3, combined.results.size, 'combined.results')

    result = combined.results[0]
    assert_equal('1', result.place, 'place')
    assert_equal(racers(:molly), result.racer, 'racer')
    assert_equal(categories(:masters_35_plus_women), result.category, 'category')
    assert_equal('30:00.00', result.time_s, 'time_s')

    result = combined.results[1]
    assert_equal('2', result.place, 'place')
    assert_equal(racers(:weaver), result.racer, 'racer')
    assert_equal(categories(:sr_p_1_2), result.category, 'category')
    assert_equal('30:01.00', result.time_s, 'time_s')

    result = combined.results[2]
    assert_equal('3', result.place, 'place')
    assert_equal(racers(:alice), result.racer, 'racer')
    assert_equal(categories(:masters_35_plus_women), result.category, 'category')
    assert_equal('35:12.00', result.time_s, 'time_s')
  end

  def test_notes
    event = SingleDayEvent.create(:name => 'New Event')
    assert_equal('', event.notes, 'New notes')
    event.notes = 'My notes'
    event.save!
    event.reload
    assert_equal('My notes', event.notes)
  end

  def test_bar_points
    event = events(:banana_belt_3)
    assert_equal(1, event.bar_points, 'BAR points')
    event.save!
    event.reload
    assert_equal(1, event.bar_points, 'BAR points')

    event = SingleDayEvent.create!
    assert_equal(1, event.bar_points, 'BAR points')
  end

  def test_races_with_results
    bb3 = events(:banana_belt_3)
    assert(bb3.races_with_results.empty?, 'No races')
    
    sr_p_1_2 = categories(:sr_p_1_2)
    bb3.races.create!(:category => sr_p_1_2)
    assert(bb3.races_with_results.empty?, 'No results')
    
    senior_women = categories(:senior_women)
    race_1 = bb3.races.create!(:category => senior_women)
    race_1.results.create!
    assert_equal([race_1], bb3.races_with_results, 'One results')
    
    race_2 = bb3.races.create!(:category => sr_p_1_2)
    race_2.results.create!
    women_4 = categories(:women_4)
    bb3.races.create!(:category => women_4)
    assert_equal([race_2, race_1], bb3.races_with_results, 'Two races with results')
    
    bb3.discipline = 'Time Trial'
    bb3.save!
    combined_results = bb3.combined_results
    assert_not_nil(combined_results, 'Combined results')
    assert_equal([race_2, race_1], bb3.races_with_results, 'Two races with results')
    race_3 = combined_results.races.first
    race_3.results.create
    assert(!race_3.results(true).empty?, 'Combined results should have results')
    assert_equal([race_2, race_1], bb3.races_with_results, 'Two races with results')
  end

  def test_full_name
    event = SingleDayEvent.create!(:name => 'Reheers', :discipline => 'Mountain Bike')
    assert_equal('Reheers', event.full_name, 'full_name')
    
    series = Series.create!(:name => 'Bend TT Series')
    series_event = series.children.create!(:name => 'Bend TT Series', :date => Date.new(2009, 4, 19))
    assert_equal('Bend TT Series', series_event.full_name, 'full_name when series name is same as event')

    stage_race = events(:mt_hood)
    stage = stage_race.children.create!(:name => stage_race.name)
    assert_equal('Mt. Hood Classic', stage.full_name, 'stage race stage full_name')

    stage_race = events(:mt_hood)
    stage = stage_race.children.create!(:name => stage_race.name)
    event = stage.children.create!(:name => 'Cooper Spur Road Race')
    assert_equal('Mt. Hood Classic: Cooper Spur Road Race', event.full_name, 'stage race event full_name')

    stage_race = MultiDayEvent.create!(:name => 'Cascade Classic')
    stage = stage_race.children.create!(:name => 'Cascade Classic')
    event = stage.children.create!(:name => 'Cascade Classic - Cascade Lakes Road Race')
    assert_equal('Cascade Classic - Cascade Lakes Road Race', event.full_name, 'stage race results full_name')
  end

  def test_updated_at
    event = SingleDayEvent.create!
    assert_not_nil event.updated_at, "updated_at after create"
    
    updated_at = event.updated_at
    event.save!
    assert_equal updated_at, event.updated_at, "Save! with no changes should not update updated_at"

    sleep 1
    event.children.create!
    event.reload
    assert event.updated_at > updated_at, "Updated at should change after adding a child event"

    sleep 1
    updated_at = event.updated_at
    event.races.create!(:category => categories(:senior_men))
    event.reload
    assert event.updated_at > updated_at, "Updated at should change after adding a race"
    
    updated_at = event.updated_at
  end


  private
  
  def assert_orphans(count, event)
    assert(event.missing_children?, "Should find missing children for #{event.name}")
    assert_equal(count, event.missing_children.size, "#{event.name} missing children")
  end
  
  def assert_no_orphans(event)
    assert(!event.missing_children?, "No missing children for #{event.name}")
    assert_equal(0, event.missing_children.size, "#{event.name} missing children count")
  end
end
