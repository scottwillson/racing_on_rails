require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EventTest < ActiveSupport::TestCase
  def test_create
    event = SingleDayEvent.create(:name => 'Saved')
    assert(event.races.empty?, "Races")
  end

  def test_find_years
    years = Event.find_all_years
    assert_equal_enumerables([Date.today.year, 2005, 2004, 2003, 2002], years, "Should find all years with events")
  end
  
  def test_defaults
    event = SingleDayEvent.new
    assert_equal(Date.today, event.date, "New event should have today's date")
    formatted_date = Date.today.strftime("%m-%d-%Y")
    assert_equal("New Event #{formatted_date}", event.name, "event name")
    assert_equal(RacingAssociation.current.state, event.state, "event.state")
    assert_equal("Road", event.discipline, "event.discipline")
    assert_equal(RacingAssociation.current.default_sanctioned_by, event.sanctioned_by, "New event sanctioned_by default")
    number_issuer = NumberIssuer.find_by_name(RacingAssociation.current.short_name)
    assert_equal(number_issuer, event.number_issuer, "New event number_issuer default")
    assert_equal true, event.notification?, "event notification?"
    event.save!
    event.reload
    assert_equal true, event.notification?, "event notification?"
  end
  
  def test_find_all_with_results
    weekly_series, events = Event.find_all_with_results
    assert_equal([], weekly_series, "weekly_series")
    expected = []
    unless RacingAssociation.current.show_only_association_sanctioned_races_on_calendar
      expected << events(:usa_cycling_event_with_results)
    end
    assert_equal(expected, events, "events")
  end
  
  def test_find_all_with_results_with_year
    weekly_series, events = Event.find_all_with_results(2003)
    assert_equal([events(:kings_valley)], events, "events")
    assert_equal([], weekly_series, "weekly_series")

    weekly_series, events = Event.find_all_with_results(2004)
    assert_equal_events([events(:banana_belt_series), events(:kings_valley_2004)], events, "events")
    assert_equal([], weekly_series, "weekly_series")

    pir_1 = events(:pir)
    pir_1.races.create!(:category => categories(:senior_men)).results.create!
    weekly_series, events = Event.find_all_with_results(2005)
    assert_equal([], events, "events")
    assert_equal([events(:pir_series)], weekly_series, "weekly_series")
  end
  
  def test_find_all_with_results_with_discipline
    weekly_series, events = Event.find_all_with_results(2003, Discipline["Road"])
    assert_equal([events(:kings_valley)], events, "events")
    assert_equal([], weekly_series, "weekly_series")

    weekly_series, events = Event.find_all_with_results(2003, Discipline["Criterium"])
    assert_equal([], events, "events")
    assert_equal([], weekly_series, "weekly_series")
    
    circuit_race = SingleDayEvent.create!(:discipline => "Circuit")
    circuit_race.races.create!(:category => categories(:senior_men)).results.create!
    
    track_event = SingleDayEvent.create!(:discipline => "Track")
    track_event.races.create!(:category => categories(:senior_men)).results.create!
    
    track_series = WeeklySeries.create!(:discipline => "Track")
    track_series_event = track_series.children.create!
    track_series_event.races.create!(:category => categories(:senior_men)).results.create!
    
    weekly_series, events = Event.find_all_with_results(Date.today.year, Discipline["Road"])
    expected = []
    unless RacingAssociation.current.show_only_association_sanctioned_races_on_calendar
      expected << events(:usa_cycling_event_with_results)
    end
    expected << circuit_race
    expected.sort!
    events.sort!
    assert_equal(expected, events, "events")
    assert_equal([], weekly_series, "weekly_series")
    
    weekly_series, events = Event.find_all_with_results(Date.today.year, Discipline["Track"])
    assert_equal([track_event], events, "events")
    assert_equal([track_series], weekly_series, "weekly_series")
  end
  
  def test_find_all_with_only_child_event_results
    series = WeeklySeries.create!
    series_event = series.children.create!
    child_event = series_event.children.create!
    child_event.races.create!(:category => categories(:senior_men)).results.create!
    
    assert(child_event.is_a?(Event), "Child event should be an Event")
    assert(!child_event.is_a?(SingleDayEvent), "Child event should not be an SingleDayEvent")

    weekly_series, events = Event.find_all_with_results
    assert_equal([series], weekly_series, "weekly_series")
  end
    
  def test_new_add_promoter
    event = SingleDayEvent.new
    candi = people(:administrator)
    event.promoter = candi
    assert_equal(candi, event.promoter, "New event promoter before save")
    event.save!
    assert_equal(candi, event.promoter, "New event promoter after save")
    event.reload
    assert_equal(candi, event.promoter, "New event promoter after reload")

    # Only email and phone
    event = SingleDayEvent.new
    nate_hobson = people(:nate_hobson)
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
    nate_hobson = people(:nate_hobson)
    event.promoter = nate_hobson
    assert_equal(nate_hobson, event.promoter, "New event promoter before save")
    event.save!
    assert_equal(nate_hobson, event.promoter, "New event promoter after save")
    event.reload
    assert_equal(nate_hobson, event.promoter, "New event promoter after reload")
  end
  
  def test_set_promoter
    event = SingleDayEvent.new
    promoter = Person.new(:name => 'Toni Kic')
    event.promoter = promoter
    assert_not_nil(event.promoter, 'event.promoter')
    assert_equal('Toni Kic', event.promoter.name, 'event.promoter.name')
  end
  
  def test_set_promoter_by_name_no_id
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross")
    assert_equal people(:promoter), event.promoter, "Should set promoter from name, even without promoter_id"
  end

  def test_set_promoter_by_name_with_id
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross", :promoter_id => people(:promoter).id)
    assert_equal people(:promoter), event.promoter, "Should set promoter from name and/or promoter_id"
  end

  def test_set_promoter_by_name_and_ignore_bogus_id
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross", :promoter_id => "1281928")
    assert_equal people(:promoter), event.promoter, "Should set promoter from name and ignore bogus promoter_id"
  end

  def test_set_promoter_by_name_and_ignore_wrong_id
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross", :promoter_id => people(:administrator).id)
    assert_equal people(:promoter), event.promoter, "Should set promoter from name, even another person's promoter_id"
  end

  def test_choose_promoter_by_id_with_multiple_same_names
    brad_ross_2 = Person.create!(:name => "Brad Ross")
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross", :promoter_id => brad_ross_2.id)
    assert_equal brad_ross_2, event.promoter, "Should use promoter_id to choose between duplicates"
  end

  def test_non_unique_promoter_wrong_id
    brad_ross_2 = Person.create!(:name => "Brad Ross")
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross", :promoter_id => "12378129")
    assert [people(:promoter), brad_ross_2].include?(event.promoter), "Should choose a Person from duplicates, even without a matching promoter_id"
  end

  def test_new_promoter_wrong_id
    event = SingleDayEvent.create!(:promoter_name => "Marie Le Blanc", :promoter_id => people(:administrator).id)
    new_promoter = Person.find_by_name("Marie Le Blanc")
    assert_not_nil new_promoter, "Should create new promoter"
    assert_equal new_promoter, event.promoter, "Should use create new promoter and ignore bad promoter_id"
  end

  def test_new_promoter_no_id
    event = SingleDayEvent.create!(:promoter_name => "Marie Le Blanc")
    new_promoter = Person.find_by_name("Marie Le Blanc")
    assert_not_nil new_promoter, "Should create new promoter"
    assert_equal new_promoter, event.promoter, "Should use create new promoter"
  end
  
  def test_set_promoter_by_alias
    event = SingleDayEvent.create!(:promoter_name => "Mollie Cameron")
    assert_equal people(:molly), event.promoter, "Should set promoter from alias"
  end
  
  def test_remove_promoter
    event = SingleDayEvent.create!(:promoter_name => "Mollie Cameron")
    event.update_attributes(:promoter_name => "")
    assert_nil event.promoter, "Blank promoter name should remove promoter"
  end

  def test_set_team_by_name_no_id
    event = SingleDayEvent.create!(:team_name => "Vanilla")
    assert_equal teams(:vanilla), event.team, "Should set team from name, even without team_id"
  end

  def test_set_team_by_name_with_id
    event = SingleDayEvent.create!(:team_name => "Vanilla", :team_id => teams(:vanilla).id)
    assert_equal teams(:vanilla), event.team, "Should set team from name and/or team_id"
  end

  def test_set_team_by_name_and_ignore_bogus_id
    event = SingleDayEvent.create!(:team_name => "Vanilla", :team_id => "1281928")
    assert_equal teams(:vanilla), event.team, "Should set team from name and ignore bogus team_id"
  end

  def test_set_team_by_name_and_ignore_wrong_id
    event = SingleDayEvent.create!(:team_name => "Vanilla", :team_id => teams(:gentle_lovers).id)
    assert_equal teams(:vanilla), event.team, "Should set team from name, even another person's team_id"
  end

  def test_new_team_wrong_id
    event = SingleDayEvent.create!(:team_name => "Katusha", :team_id => teams(:gentle_lovers).id)
    new_team = Team.find_by_name("Katusha")
    assert_not_nil new_team, "Should create new team"
    assert_equal new_team, event.team, "Should use create new team and ignore bad team_id"
  end

  def test_new_team_no_id
    event = SingleDayEvent.create!(:team_name => "Katusha")
    new_team = Team.find_by_name("Katusha")
    assert_not_nil new_team, "Should create new team"
    assert_equal new_team, event.team, "Should use create new team"
  end
  
  def test_set_team_by_alias
    event = SingleDayEvent.create!(:team_name => "Vanilla Bicycles")
    assert_equal teams(:vanilla), event.team, "Should set team from alias"
  end
  
  def test_remove_team
    event = SingleDayEvent.create!(:team_name => "Vanilla Bicycles")
    event.update_attributes(:team_name => "")
    assert_nil event.team, "Blank team name should remove team"
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
    event = Event.create!
    event.destroy
    assert !Event.exists?(event.id), "event should be deleted"

    event = Event.create!
    event.races.create! :category => categories(:cat_3)
    event.destroy
    assert !Event.exists?(event.id), "event should be deleted"

    event = SingleDayEvent.create!
    event.races.create! :category => categories(:cat_3)
    event.destroy
    assert !Event.exists?(event.id), "event should be deleted"
  end
  
  def test_destroy_races
    kings_valley = events(:kings_valley)
    assert(!kings_valley.races.empty?, "Should have races")
    kings_valley.destroy_races
    assert(kings_valley.races.empty?, "Should not have races")
  end
  
  def test_destroy_all
    SingleDayEvent.destroy_all
    Event.destroy_all
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
    last_day = mt_hood.children.last
    last_day.date = Date.new(2005, 8, 1)
    last_day.save!
    mt_hood = Event.find(mt_hood.id)
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
    assert_equal(RacingAssociation.current.default_sanctioned_by, event.sanctioned_by, 'sanctioned_by')
    assert_equal(number_issuers(:association), event.number_issuer(true), 'number_issuer')
  end
  
  def test_flyer
    event = SingleDayEvent.new
    assert_equal(nil, event.flyer, 'Blank event flyer')
    
    event.flyer = 'http://veloshop.org/pir.html'
    assert_equal('http://veloshop.org/pir.html', event.flyer, 'Other site flyer')
    
    event.flyer = '/events/pir.html'
    assert_equal("/events/pir.html", event.flyer, 'Absolute root flyer')
    
    event.flyer = '../../events/pir.html'
    assert_equal('../../events/pir.html', event.flyer, 'Relative root flyer')
  end
  
  def test_sort
    jan_event = SingleDayEvent.new(:date => Date.new(1998, 1, 4))
    march_event = MultiDayEvent.new(:date => Date.new(1998, 3, 2))
    nov_event = Series.new(:date => Date.new(1998, 11, 20))
    events = [jan_event, march_event, nov_event]
    
    assert_equal_enumerables([jan_event, march_event, nov_event], events.sort, 'Unsaved events should be sorted by date')
    march_event.date = Date.new(1999)
    assert_equal_enumerables([jan_event, nov_event, march_event], events.sort, 'Unsaved events should be sorted by date')
    
    events.each {|e| e.save!}
    assert_equal_enumerables([jan_event, nov_event, march_event], events.sort, 'Saved events should be sorted by date')
    march_event.date = Date.new(1998, 3, 2)
    assert_equal_enumerables([jan_event, march_event, nov_event], events.sort, 'Saved events should be sorted by date')
  end
  
  def test_equality
    event_1 = SingleDayEvent.create!
    event_2 = SingleDayEvent.create!
    event_1_copy = SingleDayEvent.find(event_1.id)
    
    assert_equal event_1, event_1, "event_1 == event_1"
    assert_equal event_2, event_2, "event_2 == event_2"
    assert event_1 != event_2, "event_1 != event_2"
    assert event_2 != event_1, "event_2 != event_1"
    assert_equal event_1, event_1_copy, "event_1 == event_1_copy"
    assert event_1_copy != event_2, "event_1_copy != event_2"
    assert event_2 != event_1_copy, "event_2 != event_1_copy"
  end
  
  def test_set
    event_1 = SingleDayEvent.create!
    event_2 = SingleDayEvent.create!
    set = Set.new
    set << event_1
    set << event_2
    set << event_1
    set << event_2
    set << event_1
    set << event_2
    
    assert_same_elements [ event_1, event_2 ], set.to_a, "Set equality"
  end
  
  def test_multi_day_event_children_with_no_parent
    event = SingleDayEvent.create!(:name => 'PIR')
    assert(!event.multi_day_event_children_with_no_parent?)
    assert(event.multi_day_event_children_with_no_parent.empty?)
    
    assert(!events(:kings_valley_2004).multi_day_event_children_with_no_parent?)
    assert(events(:kings_valley_2004).multi_day_event_children_with_no_parent.empty?)
    
    MultiDayEvent.create!(:name => 'PIR', :date => Date.new(RacingAssociation.current.year, 9, 12))
    event = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(RacingAssociation.current.year, 9, 12))
    assert(!(event.multi_day_event_children_with_no_parent?))
    assert(event.multi_day_event_children_with_no_parent.empty?)
      
    assert(!events(:banana_belt_series).multi_day_event_children_with_no_parent?)
    assert(!events(:banana_belt_1).multi_day_event_children_with_no_parent?)
    assert(!events(:banana_belt_2).multi_day_event_children_with_no_parent?)
    assert(!events(:banana_belt_3).multi_day_event_children_with_no_parent?)
      
    pir_1 = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(RacingAssociation.current.year + 1, 9, 5))
    assert(!pir_1.multi_day_event_children_with_no_parent?)
    assert(pir_1.multi_day_event_children_with_no_parent.empty?)
    pir_2 = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(RacingAssociation.current.year + 2, 9, 12))
    assert(!pir_1.multi_day_event_children_with_no_parent?)
    assert(!pir_2.multi_day_event_children_with_no_parent?)
    assert(pir_1.multi_day_event_children_with_no_parent.empty?)
    assert(pir_2.multi_day_event_children_with_no_parent.empty?)

    pir_3 = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(RacingAssociation.current.year + 2, 9, 17))
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
  
    mt_hood_3 = SingleDayEvent.create(:name => 'Mt. Hood Classic', :date => Date.new(RacingAssociation.current.year - 2, 7, 13))
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
    
    race.results.create!(:place => 200, :person => people(:matson))
    assert(event.has_results?(true), "Event with one result should have results")
  end
  
  def test_inspect
    event = SingleDayEvent.create!
    event.races.create!(:category => categories(:senior_men)).results.create!(:place => 1)
    event.inspect
  end
  
  def test_location
    assert_equal(RacingAssociation.current.state, SingleDayEvent.create!.location, "New event location")
    assert_equal("Canton, OH", SingleDayEvent.create!(:city => "Canton", :state => "OH").location, "City, state location")

    event = SingleDayEvent.create!(:city => "Vatican City")
    event.state = nil
    assert_equal("Vatican City", event.location, "City location")

    event = SingleDayEvent.create!
    event.state = nil
    assert_equal("", event.location, "No city, state location")
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

    stage_race = MultiDayEvent.create!(:name => 'Frozen Flatlands Omnium')
    event = stage_race.children.create!(:name => 'Frozen Flatlands Time Trial')
    assert_equal('Frozen Flatlands Omnium: Frozen Flatlands Time Trial', event.full_name, 'stage race results full_name')
  end
  
  def test_team_name
    assert_equal(nil, Event.new.team_name, "team_name")
    assert_equal("", Event.new(:team => Team.new(:name => "")).team_name, "team_name")
    assert_equal("Vanilla", Event.new(:team => Team.new(:name => "Vanilla")).team_name, "team_name")
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
  
  def test_competition_and_event_associations
    series = Series.create!
    child_event = series.children.create!
    overall = series.create_overall
    
    assert(series.valid?, series.errors.full_messages.join(", "))
    assert(child_event.valid?, series.errors.full_messages.join(", "))
    assert(overall.valid?, series.errors.full_messages.join(", "))
    
    assert_equal_events([child_event], series.children(true), "series.children should not include competitions")
    assert_equal_events([overall], series.child_competitions(true), "series.child_competitions should only include competitions")
    assert_equal(overall, series.overall(true), "series.overall")
    assert_equal(0, series.competition_event_memberships.size, "series.competition_event_memberships")
    assert_equal_events([], series.competitions(true), "series.competitions")    

    assert_equal_events([], child_event.children(true), "child_event.children")
    assert_equal_events([], child_event.child_competitions(true), "child_event.child_competitions")
    assert_nil(child_event.overall(true), "child_event.overall")
    assert_equal(1, child_event.competition_event_memberships(true).size, "child_event.competition_event_memberships")
    competition_event_membership = child_event.competition_event_memberships.first
    assert_equal(child_event, competition_event_membership.event, "competition_event_membership.event")
    assert_equal(overall, competition_event_membership.competition, "competition_event_membership.competition")
    
    assert_equal_events([overall], child_event.competitions(true), "competitions should only include competitions")
    assert_equal_events([], child_event.children_with_results(true), "children_with_results")
    assert_equal_events([], child_event.children_and_child_competitions_with_results(true), "children_and_child_competitions_with_results")
  end

  def test_children_with_results
    event = SingleDayEvent.create!
    assert_equal(0, event.children_with_results.size, "events_with_results: no child")
    assert_equal(0, event.children_and_child_competitions_with_results.size, "children_and_child_competitions_with_results: no child")

    event.children.create!
    assert_equal(0, event.children_with_results.size, "events_with_results: child with no results")
    assert_equal(0, event.children_and_child_competitions_with_results.size, "children_and_child_competitions_with_results: child with no results")

    event.children.create!.races.create!(:category => categories(:cat_4_women)).results.create!
    assert_equal(1, event.children_with_results.size, "cached: events_with_results: 1 children with results")
    assert_equal(1, event.children_with_results(true).size, "refresh cache: events_with_results: 1 children with results")
    assert_equal(1, event.children_and_child_competitions_with_results(true).size, "refresh cache: children_and_child_competitions_with_results: 1 children with results")

    event.children.create!.races.create!(:category => categories(:cat_4_women)).results.create!
    assert_equal(2, event.children_with_results(true).size, "refresh cache: events_with_results: 2 children with results")
    assert_equal(2, event.children_and_child_competitions_with_results(true).size, "refresh cache: children_and_child_competitions_with_results: 2 children with results")
  end
  
  def test_children_with_results_only_child_events
    series = WeeklySeries.create!
    series_event = series.children.create!
    child_event = series_event.children.create!
    child_event.races.create!(:category => categories(:senior_men)).results.create!

    series.reload

    assert_equal(1, series.children_with_results.size, "Should have child with results")
    assert_equal(series_event, series.children_with_results.first, "Should have child with results")
    assert_equal(1, series_event.children_with_results.size, "Should have child with results")
    assert_equal(child_event, series_event.children_with_results.first, "Should have child with results")
  end
  
  def test_has_results_including_children
    series = WeeklySeries.create!
    series_event = series.children.create!
    child_event = series_event.children.create!
    child_event.races.create!(:category => categories(:senior_men)).results.create!

    series.reload

    assert(series.has_results_including_children?, "Series has_results_including_children?")
    assert(series_event.has_results_including_children?, "Series Event has_results_including_children?")
    assert(child_event.has_results_including_children?, "Series Event child has_results_including_children?")
  end
  
  def test_postponed
    event = events(:banana_belt_3)
    assert !event.postponed?, "postponed?"
    event.postponed = true
    event.save!
    assert event.postponed?, "postponed?"
  end
  
  def test_single_day_event_categories
    event = SingleDayEvent.create!
    assert_equal [], event.categories, "categories for event with no races"
    
    event.races.create!(:category => categories(:senior_men))
    assert_same_elements [ categories(:senior_men) ], event.categories, "categories for event with one race"
    
    event.races.create!(:category => categories(:senior_women))
    assert_same_elements [ categories(:senior_men), categories(:senior_women) ], event.categories, "categories for event with two races"
  end
  
  def test_multiday_event_categories
    parent = MultiDayEvent.create!(:name => "parent")
    assert_equal [], parent.categories, "categories for event with no races"
    
    event = parent.children.create!(:name => "child")
    event.races.create!(:category => categories(:senior_men))
    assert_same_elements [ categories(:senior_men) ], parent.categories, "categories from child"
    
    event.races.create!(:category => categories(:senior_women))
    parent.races.create!(:category => categories(:senior_men))
    parent.races.create!(:category => categories(:men_4_5))
    assert_same_elements(
      [ categories(:senior_men), categories(:senior_men), categories(:men_4_5), categories(:senior_women) ], 
      parent.categories, 
      "categories for event with two races"
    )
  end

  def test_editable_by
    assert_equal [], Event.editable_by(people(:alice)), "Alice can't edit any events"
    assert_same_elements [ events(:banana_belt_series), events(:banana_belt_1), events(:banana_belt_2), events(:banana_belt_3),
                           events(:mt_hood), events(:mt_hood_1), events(:mt_hood_2), events(:series_parent), events(:lost_series_child) ], 
      Event.editable_by(people(:promoter)), 
      "Promoter can edit his events"
      
    assert_equal_enumerables Event.all, Event.editable_by(people(:administrator)), "Administrator can edit all events"
  end
  
  def test_today_and_future
    assert Event.today_and_future.include?(events(:lost_series_child)), "today_and_future scope should include Lost Series child event"
    assert Event.today_and_future.include?(events(:future_national_federation_event)), "today_and_future scope should include future event"
    assert !Event.today_and_future.include?(events(:banana_belt_3)), "today_and_future scope should not include Banana Belt event"
  end

  def test_propagate_races
    events(:kings_valley).propagate_races
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
