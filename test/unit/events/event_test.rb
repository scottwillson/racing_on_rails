require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class EventTest < ActiveSupport::TestCase
  def test_validate_discipline
    FactoryGirl.create(:discipline, :name => "Road")
    event = Event.new(:discipline => "Foo")
    assert !event.valid?, "Event with bogus Discipline should not be valid"
    assert event.errors[:discipline]
  end

  def test_find_years
    Timecop.freeze(Date.new(2012)) do
      FactoryGirl.create(:event, :date => Date.new(2007))
      FactoryGirl.create(:event, :date => Date.new(2008))
      FactoryGirl.create(:event, :date => Date.new(2009))
      years = Event.find_all_years
      assert_equal_enumerables [ 2012, 2011, 2010, 2009, 2008, 2007 ], years, "Should find all years with events"
    end
  end
  
  def test_defaults
    number_issuer = NumberIssuer.create!(:name => RacingAssociation.current.short_name)
    event = SingleDayEvent.new
    assert_equal(Time.zone.today, event.date, "New event should have today's date")
    formatted_date = Time.zone.today.strftime("%m-%d-%Y")
    assert_equal("New Event #{formatted_date}", event.name, "event name")
    assert_equal(RacingAssociation.current.state, event.state, "event.state")
    assert_equal("Road", event.discipline, "event.discipline")
    assert_equal(RacingAssociation.current.default_sanctioned_by, event.sanctioned_by, "New event sanctioned_by default")
    number_issuer = NumberIssuer.find_by_name(RacingAssociation.current.short_name)
    assert_equal(number_issuer, event.number_issuer, "New event number_issuer default")
    assert_equal(RacingAssociation.current.default_sanctioned_by, event.sanctioned_by, 'sanctioned_by')
    assert_equal(number_issuer, event.number_issuer(true), 'number_issuer')

    assert_equal true, event.notification?, "event notification?"
    event.save!
    event.reload
    assert_equal true, event.notification?, "event notification?"
  end
  
  def test_find_all_with_results
    event = FactoryGirl.create(:result).event
    weekly_series, events = Event.find_all_with_results
    assert_equal([], weekly_series, "weekly_series")
    assert_equal([ event ], events, "events")
  end
  
  def test_find_all_with_results_with_year
    event_with_results = FactoryGirl.create(:event, :date => Date.new(2003))
    race = FactoryGirl.create(:race, :event => event_with_results)
    FactoryGirl.create(:result, :race => race)

    # Event and race + event with no results
    FactoryGirl.create(:event, :date => Date.new(2003))
    FactoryGirl.create(:race)
    
    weekly_series, events = Event.find_all_with_results(2003)
    assert_equal([ event_with_results ], events, "events")
    assert_equal([], weekly_series, "weekly_series")

    event_with_results = FactoryGirl.create(:event, :date => Date.new(2004))
    race = FactoryGirl.create(:race, :event => event_with_results)
    FactoryGirl.create(:result, :race => race)
    
    weekly_series_with_results = FactoryGirl.create(:weekly_series, :date => Date.new(2004))
    series_event = weekly_series_with_results.children.create!
    race = FactoryGirl.create(:race, :event => series_event)
    FactoryGirl.create(:result, :race => race)
    
    weekly_series, events = Event.find_all_with_results(2004)
    assert_equal_events([ event_with_results ], events, "events")
    assert_equal([ weekly_series_with_results], weekly_series, "weekly_series")

    weekly_series, events = Event.find_all_with_results(2005)
    assert_equal([], events, "events")
    assert_equal([], weekly_series, "weekly_series")
  end
  
  def test_find_all_with_results_with_discipline
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Circuit")
    FactoryGirl.create(:discipline, :name => "Criterium")
    FactoryGirl.create(:discipline, :name => "Track")
    
    event_with_results = FactoryGirl.create(:event, :date => Date.new(2003))
    race = FactoryGirl.create(:race, :event => event_with_results)
    FactoryGirl.create(:result, :race => race)

    weekly_series, events = Event.find_all_with_results(2003, Discipline["Road"])
    assert_equal([ event_with_results ], events, "events")
    assert_equal([], weekly_series, "weekly_series")

    weekly_series, events = Event.find_all_with_results(2003, Discipline["Criterium"])
    assert_equal([], events, "events")
    assert_equal([], weekly_series, "weekly_series")
    
    circuit_race = FactoryGirl.create(:event, :discipline => "Circuit")
    category = FactoryGirl.create(:category)
    circuit_race.races.create!(:category => category).results.create!
    
    track_event = FactoryGirl.create(:event, :discipline => "Track")
    track_event.races.create!(:category => category).results.create!
    
    track_series = WeeklySeries.create!(:discipline => "Track")
    track_series_event = track_series.children.create!
    track_series_event.races.create!(:category => category).results.create!
    
    weekly_series, events = Event.find_all_with_results(Time.zone.today.year, Discipline["Road"])
    expected = []
    expected << circuit_race
    expected.sort!
    events.sort!
    assert_equal(expected, events, "events")
    assert_equal([], weekly_series, "weekly_series")
    
    weekly_series, events = Event.find_all_with_results(Time.zone.today.year, Discipline["Track"])
    assert_equal([track_event], events, "events")
    assert_equal([track_series], weekly_series, "weekly_series")
  end
  
  def test_find_all_with_only_child_event_results
    series = WeeklySeries.create!
    series_event = series.children.create!
    child_event = series_event.children.create!
    child_event.races.create!(:category => FactoryGirl.create(:category)).results.create!
    
    assert(child_event.is_a?(Event), "Child event should be an Event")
    assert(!child_event.is_a?(SingleDayEvent), "Child event should not be an SingleDayEvent")

    weekly_series, events = Event.find_all_with_results
    assert_equal([series], weekly_series, "weekly_series")
  end
  
  def test_set_promoter_by_name_no_id
    promoter = FactoryGirl.create(:person, :name => "Brad Ross")
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross")
    assert_equal promoter, event.promoter, "Should set promoter from name, even without promoter_id"
  end

  def test_set_promoter_by_name_with_id
    promoter = FactoryGirl.create(:person, :name => "Brad Ross")
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross", :promoter_id => promoter.id)
    assert_equal promoter, event.promoter, "Should set promoter from name and/or promoter_id"
  end

  def test_set_promoter_by_name_and_ignore_bogus_id
    promoter = FactoryGirl.create(:person, :name => "Brad Ross")
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross", :promoter_id => "1281928")
    assert_equal promoter, event.promoter, "Should set promoter from name and ignore bogus promoter_id"
  end

  def test_set_promoter_by_name_and_ignore_wrong_id
    promoter = FactoryGirl.create(:person, :name => "Brad Ross")
    person = FactoryGirl.create(:person)
    
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross", :promoter_id => person.id)
    assert_equal promoter, event.promoter, "Should set promoter from name, even another person's promoter_id"
  end

  def test_choose_promoter_by_id_with_multiple_same_names
    promoter = FactoryGirl.create(:person, :name => "Brad Ross")
    brad_ross_2 = Person.create!(:name => "Brad Ross")
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross", :promoter_id => brad_ross_2.id)
    assert_equal brad_ross_2, event.promoter, "Should use promoter_id to choose between duplicates"
  end

  def test_non_unique_promoter_wrong_id
    promoter = FactoryGirl.create(:person, :name => "Brad Ross")
    brad_ross_2 = Person.create!(:name => "Brad Ross")
    event = SingleDayEvent.create!(:promoter_name => "Brad Ross", :promoter_id => "12378129")
    assert [promoter, brad_ross_2].include?(event.promoter), "Should choose a Person from duplicates, even without a matching promoter_id"
  end

  def test_new_promoter_wrong_id
    event = SingleDayEvent.create!(:promoter_name => "Marie Le Blanc", :promoter_id => FactoryGirl.create(:person).id)
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
    promoter = FactoryGirl.create(:person, :name => "Molly Cameron")
    promoter.aliases.create(:name => "Mollie Cameron")
    event = SingleDayEvent.create!(:promoter_name => "Mollie Cameron")
    assert_equal promoter, event.promoter, "Should set promoter from alias"
  end
  
  def test_remove_promoter
    promoter = FactoryGirl.create(:person, :name => "Mollie Cameron")
    event = SingleDayEvent.create!(:promoter_name => "Mollie Cameron")
    event.update_attributes(:promoter_name => "")
    assert_nil event.promoter, "Blank promoter name should remove promoter"
  end

  def test_set_team_by_name_no_id
    team = FactoryGirl.create(:team, :name => "Vanilla")
    event = SingleDayEvent.create!(:team_name => "Vanilla")
    assert_equal team, event.team, "Should set team from name, even without team_id"
  end

  def test_set_team_by_name_with_id
    team = FactoryGirl.create(:team, :name => "Vanilla")
    event = SingleDayEvent.create!(:team_name => "Vanilla", :team_id => team.id)
    assert_equal team, event.team, "Should set team from name and/or team_id"
  end

  def test_set_team_by_name_and_ignore_bogus_id
    team = FactoryGirl.create(:team, :name => "Vanilla")
    event = SingleDayEvent.create!(:team_name => "Vanilla", :team_id => "1281928")
    assert_equal team, event.team, "Should set team from name and ignore bogus team_id"
  end

  def test_set_team_by_name_and_ignore_wrong_id
    team = FactoryGirl.create(:team, :name => "Vanilla")
    another_team = FactoryGirl.create(:team)
    event = SingleDayEvent.create!(:team_name => "Vanilla", :team_id => another_team.id)
    assert_equal team, event.team, "Should set team from name, even another person's team_id"
  end

  def test_new_team_wrong_id
    team = FactoryGirl.create(:team, :name => "Vanilla")
    event = SingleDayEvent.create!(:team_name => "Katusha", :team_id => team.id)
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
    team = FactoryGirl.create(:team, :name => "Vanilla")
    team.aliases.create!(:name => "Vanilla Bicycles")
    event = SingleDayEvent.create!(:team_name => "Vanilla Bicycles")
    assert_equal team, event.team, "Should set team from alias"
  end
  
  def test_remove_team
    event = SingleDayEvent.create!(:team_name => "Vanilla Bicycles")
    event.update_attributes(:team_name => "")
    assert_nil event.team, "Blank team name should remove team"
  end
  
  def test_team_name
    assert_equal(nil, Event.new.team_name, "team_name")
    assert_equal("", Event.new(:team => Team.new(:name => "")).team_name, "team_name")
    assert_equal("Vanilla", Event.new(:team => Team.new(:name => "Vanilla")).team_name, "team_name")
  end

  def test_destroy_races
    kings_valley = FactoryGirl.create(:event)
    kings_valley.races.create!(:category => FactoryGirl.create(:category))
    kings_valley.races.create!(:category => FactoryGirl.create(:category))
    kings_valley.races.create!(:category => FactoryGirl.create(:category))
    
    assert(!kings_valley.races.empty?, "Should have races")
    kings_valley.destroy_races
    assert(kings_valley.races.empty?, "Should not have races")
  end
  
  def test_no_delete_with_results
    event = FactoryGirl.create(:result).event
    assert(!event.destroy, 'Should not be destroyed')
    assert(!event.errors.empty?, 'Should have errors')
    assert(Event.exists?(event.id), "Kings Valley should not be deleted")
  end
  
  def test_multi_day_event_children_with_no_parent
    event = SingleDayEvent.create!(:name => 'PIR')
    assert(!event.multi_day_event_children_with_no_parent?)
    assert(event.multi_day_event_children_with_no_parent.empty?)
       
    event = FactoryGirl.create(:event) 
    assert(!event.multi_day_event_children_with_no_parent?)
    assert(event.multi_day_event_children_with_no_parent.empty?)
    
    MultiDayEvent.create!(:name => 'PIR', :date => Date.new(RacingAssociation.current.year, 9, 12))
    event = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(RacingAssociation.current.year, 9, 12))
    assert(!(event.multi_day_event_children_with_no_parent?))
    assert(event.multi_day_event_children_with_no_parent.empty?)
     
    series = FactoryGirl.create(:series)
    3.times { series.children.create! }
    assert(!series.multi_day_event_children_with_no_parent?)
    assert(!series.children[0].multi_day_event_children_with_no_parent?)
    assert(!series.children[1].multi_day_event_children_with_no_parent?)
    assert(!series.children[2].multi_day_event_children_with_no_parent?)
      
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
    
    mt_hood = FactoryGirl.create(:stage_race, :name => "Mt. Hood Classic")
    assert(!mt_hood.multi_day_event_children_with_no_parent?)
    assert(!mt_hood.children[0].multi_day_event_children_with_no_parent?)
    assert(!mt_hood.children[1].multi_day_event_children_with_no_parent?)
  
    mt_hood_3 = SingleDayEvent.create(:name => 'Mt. Hood Classic')
    assert(!mt_hood.multi_day_event_children_with_no_parent?)
    assert(!mt_hood.children[0].multi_day_event_children_with_no_parent?)
    assert(!mt_hood.children[1].multi_day_event_children_with_no_parent?)

    assert(!mt_hood_3.multi_day_event_children_with_no_parent?)
    assert !mt_hood_3.multi_day_event_children_with_no_parent.present?
  end

  def test_missing_children
    event = SingleDayEvent.create!(:name => 'PIR')
    assert_no_orphans(event)
    
    SingleDayEvent.create!(:name => 'PIR', :date => Date.new(Time.zone.today.year, 9, 12))
    event = MultiDayEvent.create!(:name => 'PIR')
    assert_orphans(2, event)
 
    banana_belt_series = FactoryGirl.create(:series)
    banana_belt_series.children.create!
    assert_no_orphans(banana_belt_series)
    assert_no_orphans(banana_belt_series.children.first)
  
    pir_1 = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(2009, 9, 5))
    assert_no_orphans(pir_1)
    pir_2 = SingleDayEvent.create!(:name => 'PIR', :date => Date.new(2010, 9, 12))
    assert_no_orphans(pir_1)
    assert_no_orphans(pir_2)
   
    stage_race = FactoryGirl.create(:multi_day_event)
    stage_1 = stage_race.children.create!
    stage_2 = stage_race.children.create!
    assert_no_orphans(stage_race)
    assert_no_orphans(stage_1)
    assert_no_orphans(stage_2)
 
    # Different year, same name 
    mt_hood_3 = SingleDayEvent.create(:name => stage_race.name, :date => Date.new(2005, 7, 13))
    assert_no_orphans(stage_race)
    assert_no_orphans(stage_1)
    assert_no_orphans(stage_2)
    assert_no_orphans(mt_hood_3)
  end
  
  def test_has_results
    assert(!Event.new.has_results?, "New Event should not have results")
    
    event = SingleDayEvent.create!
    race = event.races.create!(:category => FactoryGirl.create(:category))
    assert(!event.has_results?, "Event with race, but no results should not have results")
    
    race.results.create!(:place => 200, :person => FactoryGirl.create(:person))
    assert(event.has_results?(true), "Event with one result should have results")
  end
  
  def test_inspect
    event = SingleDayEvent.create!
    event.races.create!(:category => FactoryGirl.create(:category)).results.create!(:place => 1)
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

  def test_races_with_results
    bb3 = FactoryGirl.create(:event)
    assert(bb3.races_with_results.empty?, 'No races')
    
    sr_p_1_2 = FactoryGirl.create(:category)
    bb3.races.create!(:category => sr_p_1_2)
    assert(bb3.races_with_results.empty?, 'No results')
    
    senior_women = FactoryGirl.create(:category)
    race_1 = bb3.races.create!(:category => senior_women)
    race_1.results.create!
    assert_equal([race_1], bb3.races_with_results, 'One results')
    
    race_2 = bb3.races.create!(:category => sr_p_1_2)
    race_2.results.create!
    women_4 = FactoryGirl.create(:category)
    bb3.races.create!(:category => women_4)
    assert_equal([race_2, race_1], bb3.races_with_results, 'Two races with results')
  end

  def test_updated_at
    event = nil
    updated_at = nil
    
    Timecop.freeze(4.days.ago) do
      event = SingleDayEvent.create!
      assert_not_nil event.updated_at, "updated_at after create"
      updated_at = event.updated_at
    end

    Timecop.freeze(3.days.ago) do
      event.save!
      assert_equal updated_at, event.updated_at, "Save! with no changes should not update updated_at"
    end

    Timecop.freeze(2.days.ago) do
      event.children.create!
      event.reload
      assert event.updated_at > updated_at, "Updated at should change after adding a child event"
    end

    Timecop.freeze(1.day.ago) do
      updated_at = event.updated_at
      event.races.create!(:category => FactoryGirl.create(:category))
      event.reload
      assert event.updated_at > updated_at, "Updated at should change after adding a race"
    end
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

    category = FactoryGirl.create(:category)
    event.children.create!.races.create!(:category => category).results.create!
    assert_equal(1, event.children_with_results.size, "cached: events_with_results: 1 children with results")
    assert_equal(1, event.children_with_results(true).size, "refresh cache: events_with_results: 1 children with results")
    assert_equal(1, event.children_and_child_competitions_with_results(true).size, "refresh cache: children_and_child_competitions_with_results: 1 children with results")

    event.children.create!.races.create!(:category => category).results.create!
    assert_equal(2, event.children_with_results(true).size, "refresh cache: events_with_results: 2 children with results")
    assert_equal(2, event.children_and_child_competitions_with_results(true).size, "refresh cache: children_and_child_competitions_with_results: 2 children with results")
  end
  
  def test_children_with_results_only_child_events
    series_event = FactoryGirl.create(:series_event)
    child_event = series_event.children.create!
    FactoryGirl.create(:result, :race => FactoryGirl.create(:race, :event => child_event))
    series = series_event.parent

    assert_equal(1, series.children_with_results(true).size, "Should have child with results")
    assert_equal(series_event, series.children_with_results.first, "Should have child with results")
    assert_equal(1, series_event.children_with_results.size, "Should have child with results")
    assert_equal(child_event, series_event.children_with_results.first, "Should have child with results")
  end
  
  def test_has_results_including_children
    series_event = FactoryGirl.create(:weekly_series_event)
    child_event = series_event.children.create!
    FactoryGirl.create(:result, :race => FactoryGirl.create(:race, :event => child_event))
    series = series_event.parent

    assert(series.has_results_including_children?(true), "Series has_results_including_children?")
    assert(series_event.has_results_including_children?, "Series Event has_results_including_children?")
    assert(child_event.has_results_including_children?, "Series Event child has_results_including_children?")
  end
  
  def test_single_day_event_categories
    event = SingleDayEvent.create!
    assert_equal [], event.categories, "categories for event with no races"
    
    category_1 = FactoryGirl.create(:category)
    event.races.create!(:category => category_1)
    assert_same_elements [ category_1 ], event.categories, "categories for event with one race"
    
    category_2 = FactoryGirl.create(:category)
    event.races.create!(:category => category_2)
    assert_same_elements [ category_1, category_2 ], event.categories, "categories for event with two races"
  end
  
  def test_multiday_event_categories
    parent = MultiDayEvent.create!(:name => "parent")
    assert_equal [], parent.categories, "categories for event with no races"
    
    event = parent.children.create!(:name => "child")
    category_1 = FactoryGirl.create(:category)
    event.races.create!(:category => category_1)
    assert_same_elements [ category_1 ], parent.categories, "categories from child"
    
    category_2 = FactoryGirl.create(:category)
    category_3 = FactoryGirl.create(:category)
    category_4 = FactoryGirl.create(:category)
    event.races.create!(:category => category_2)
    parent.races.create!(:category => category_3)
    parent.races.create!(:category => category_4)
    assert_same_elements(
      [ category_1, category_2, category_3, category_4 ], 
      parent.categories, 
      "categories for event with two races"
    )
  end

  def test_editable_by
    event_1 = FactoryGirl.create(:event)
    event_2 = FactoryGirl.create(:event)

    racer = FactoryGirl.create(:person)
    assert_equal [], Event.editable_by(racer), "Random person can't edit any events"

    assert_equal [ event_1 ], Event.editable_by(event_1.promoter), "Promoter can edit own events"
    assert_equal [ event_2 ], Event.editable_by(event_2.promoter), "Promoter can edit own events"

    administrator = FactoryGirl.create(:administrator)
    assert_equal_enumerables Event.all, Event.editable_by(administrator), "Administrator can edit all events"
  end
  
  def test_today_and_future
    past_event = FactoryGirl.create(:event, :date => 1.day.ago.to_date)
    today_event = FactoryGirl.create(:event)
    future_event = FactoryGirl.create(:event, :date => 1.day.from_now.to_date)

    assert Event.today_and_future.include?(today_event), "today_and_future scope should include event from today"
    assert Event.today_and_future.include?(future_event), "today_and_future scope should include future event"
    assert !Event.today_and_future.include?(past_event), "today_and_future scope should not include past event with date of #{past_event.date}"
  end

  def test_propagate_races
    FactoryGirl.create(:event).propagate_races
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
