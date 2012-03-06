# coding: utf-8

require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::PeopleControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
    
    @cyclocross = FactoryGirl.create(:cyclocross_discipline)
    FactoryGirl.create(:discipline, :name => "Downhill")
    @mountain_bike = FactoryGirl.create(:mtb_discipline)
    @road = FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Singlespeed")
    FactoryGirl.create(:discipline, :name => "Track")
    @association = FactoryGirl.create(:number_issuer)    
  end

  def test_toggle_member
    molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
    assert_equal(true, molly.member, 'member before update')
    post(:toggle_member, :id => molly.to_param)
    assert_response :success
    assert_template("shared/_member")
    molly.reload
    assert_equal(false, molly.member, 'member after update')

    post(:toggle_member, :id => molly.to_param)
    assert_response :success
    assert_template("shared/_member")
    molly.reload
    assert_equal(true, molly.member, 'member after second update')
  end
  
  def test_new
    get(:new)
    assert_response :success
    assert_template("admin/people/edit")
    assert_not_nil(assigns["person"], "Should assign person as 'person'")
    assert_not_nil(assigns["race_numbers"], "Should assign person's number for current year as 'race_numbers'")
  end

  def test_edit
    alice = FactoryGirl.create(:person)

    get(:edit, :id => alice.to_param)
    assert_response :success
    assert_template("admin/people/edit")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(alice, assigns['person'], 'Should assign Alice to person')
    assert_nil(assigns['event'], "Should not assign 'event'")
  end

  def test_edit_created_by_import_file
    alice = FactoryGirl.create(:person)
    alice.updater = ImportFile.create!(:name => "some_very_long_import_file_name.xls")
    alice.save!

    get(:edit, :id => alice.to_param)
    assert_response :success
    assert_template("admin/people/edit")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(alice, assigns['person'], 'Should assign Alice to person')
  end
  
  def test_create
    assert_equal([], Person.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    
    post(:create, {"person"=>{
                        "member_from(1i)"=>"", "member_from(2i)"=>"", "member_from(3i)"=>"", 
                        "member_to(1i)"=>"", "member_to(2i)"=>"", "member_to(3i)"=>"", 
                        "work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", 
                        "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", 
                        "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", 
                        "dh_number"=>"", "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", 
                        "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, "commit"=>"Save"})
    
    assert assigns['person'].errors.empty?, assigns['person'].errors.full_messages.join
    
    assert(flash.empty?, "Flash should be empty, but was: #{flash}")
    knowlsons = Person.find_all_by_name('Jon Knowlson')
    assert(!knowlsons.empty?, 'Knowlson should be created')
    assert_redirected_to(edit_admin_person_path(knowlsons.first))
    assert_nil(knowlsons.first.member_from, 'member_from after update')
    assert_nil(knowlsons.first.member_to, 'member_to after update')
    assert_equal(@administrator, knowlsons.first.created_by, "created by")
    assert_equal("Candi Murray", knowlsons.first.created_by.name, "created by")
  end

  def test_update_new_number
    Timecop.freeze(Date.new(2008, 6)) do
      molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron", :road_number => "202")
      assert_equal('202', molly.road_number(true, 2008), 'Road number')
      assert_equal('202', molly.road_number(true), 'Road number')
      molly_road_number = RaceNumber.last

      put(:update, {"commit"=>"Save", 
                     "number_year" => Time.zone.today.year.to_s,
                     "number_issuer_id"=>[@association.to_param], "number_value"=>["AZY"], 
                     "discipline_id" => [@mountain_bike.id.to_s],
                     "number"=>{molly_road_number.to_param =>{"value"=>"202"}},
                     "person"=>{"work_phone"=>"", "date_of_birth(2i)"=>"1", "occupation"=>"engineer", "city"=>"Wilsonville", 
                     "cell_fax"=>"", "zip"=>"97070", 
                     "date_of_birth(3i)"=>"1", "mtb_category"=>"Spt", "dh_category"=>"",
                     "member"=>"1", "gender"=>"M", "notes"=>"rm", "ccx_category"=>"", "team_name"=>"", "road_category"=>"5", 
                     "street"=>"31153 SW Willamette Hwy W", 
                     "track_category"=>"", "home_phone"=>"503-582-8823", "first_name"=>"Paul", "last_name"=>"Formiller", 
                     "date_of_birth(1i)"=>"1969", 
                     "member_from(1i)"=>"", "member_from(2i)"=>"", "member_from(3i)"=>"", 
                     "member_to(1i)"=>"", "member_to(2i)"=>"", "member_to(3i)"=>"", 
                     "email"=>"paul.formiller@verizon.net", "state"=>"OR"}, 
                     "id"=>molly.to_param}
      )
      assert assigns(:person).errors.empty?, assigns(:person).errors.full_messages.join(", ")
      assert(flash.empty?, "flash empty? but was: #{flash}")
      assert_redirected_to edit_admin_person_path(molly)
      molly.reload
      assert_equal('202', molly.road_number(true, 2008), 'Road number should not be updated')
      assert_equal('AZY', molly.xc_number(true, 2008), 'MTB number should be updated')
      assert_nil(molly.member_from, 'member_from after update')
      assert_nil(molly.member_to, 'member_to after update')
      assert_nil(RaceNumber.find(molly_road_number.to_param).updated_by, "updated_by")
      assert_equal(@administrator, RaceNumber.find_by_value("AZY").updated_by, "updated_by")
    end
  end

  def test_create_with_road_number
    assert_equal([], Person.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    
    post(:create, {
      "person"=>{"work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", 
        "member_from(1i)"=>"2004", "member_from(2i)"=>"2", "member_from(3i)"=>"16", 
        "member_to(1i)"=>"2004", "member_to(2i)"=>"12", "member_to(3i)"=>"31", 
        "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", 
        "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", "dh_number"=>"", 
        "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, 
        "number_issuer_id"=>[@association.to_param, @association.to_param], "number_value"=>["8977", "BBB9"],
        "discipline_id"=>[@road.id.to_s, @mountain_bike.id.to_s], 
        :number_year => '2007', "official" => "0",
      "commit"=>"Save"})
    
    assert assigns['person'].errors.empty?, assigns['person'].errors.full_messages.join
    
    assert(flash.empty?, "flash empty? #{flash}")
    knowlsons = Person.find_all_by_name('Jon Knowlson')
    assert(!knowlsons.empty?, 'Knowlson should be created')
    assert_redirected_to(edit_admin_person_path(knowlsons.first))
    race_numbers = knowlsons.first.race_numbers
    assert_equal(2, race_numbers.size, 'Knowlson race numbers')
    
    race_number = RaceNumber.first(:conditions => ['discipline_id=? and year=? and person_id=?', Discipline[:road].id, 2007, knowlsons.first.id])
    assert_not_nil(race_number, 'Road number')
    assert_equal(2007, race_number.year, 'Road number year')
    assert_equal('8977', race_number.value, 'Road number value')
    assert_equal(Discipline[:road], race_number.discipline, 'Road number discipline')
    assert_equal(@association, race_number.number_issuer, 'Road number issuer')
    
    race_number = RaceNumber.first(:conditions => ['discipline_id=? and year=? and person_id=?', Discipline[:mountain_bike].id, 2007, knowlsons.first.id])
    assert_not_nil(race_number, 'MTB number')
    assert_equal(2007, race_number.year, 'MTB number year')
    assert_equal('BBB9', race_number.value, 'MTB number value')
    assert_equal(Discipline[:mountain_bike], race_number.discipline, 'MTB number discipline')
    assert_equal(@association, race_number.number_issuer, 'MTB number issuer')

    assert_equal_dates('2004-02-16', knowlsons.first.member_from, 'member_from after update')
    assert_equal_dates('2004-12-31', knowlsons.first.member_to, 'member_to after update')
  end
  
  def test_create_with_duplicate_road_number
    assert_equal([], Person.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    
    post(:create, {
      "person"=>{"work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", 
        "member_from(1i)"=>"2004", "member_from(2i)"=>"2", "member_from(3i)"=>"16", 
        "member_to(1i)"=>"2004", "member_to(2i)"=>"12", "member_to(3i)"=>"31", 
        "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", 
        "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", "dh_number"=>"", 
        "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, 
      "number_issuer_id"=>["2", "2"], "number_value"=>["104", "BBB9"], "discipline_id"=>["4", "3"], :number_year => '2004',
      "commit"=>"Save"})
    
    assert_not_nil(assigns['person'], "Should assign person")
    assert(assigns['person'].errors.empty?, "Person should not have errors")
    
    knowlsons = Person.all( :conditions => { :first_name => "Jon", :last_name => "Knowlson" })
    assert_equal(1, knowlsons.size, "Should have two Knowlsons")
    knowlsons.each do |knowlson|
      assert_equal(2, knowlson.race_numbers.size, 'Knowlson race numbers')
    end
  end
  
  def test_create_with_empty_password_and_no_numbers
    post :create,  :person => { :login => "", :password_confirmation => "", :password => "", :team_name => "", 
                                :first_name => "Henry", :last_name => "David", :license => "" }, :number_issuer_id => [ { "1" => nil } ]
    assert_not_nil assigns(:person), "@person"
    assert assigns(:person).errors.empty?, "Did no expect @person errors: #{assigns(:person).errors.full_messages.join(', ')}"
    assert_redirected_to edit_admin_person_path(assigns(:person))
  end
    
  def test_update
    vanilla = FactoryGirl.create(:team)
    molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron", :road_number => "2", :team => vanilla)
    assert_equal 1, molly.versions.size, "versions"
    molly_road_number = RaceNumber.first
    
    put(:update, {"commit"=>"Save", 
                   "number_year" => Time.zone.today.year.to_s,
                   "number_issuer_id"=>@association.to_param, "number_value"=>[""], "discipline_id"=>@cyclocross.to_param,
                   "number"=>{molly_road_number.to_param=>{"value"=>"222"}},
                   "person"=>{
                     "member_from(1i)"=>"2004", "member_from(2i)"=>"2", "member_from(3i)"=>"16", 
                     "member_to(1i)"=>"2004", "member_to(2i)"=>"12", "member_to(3i)"=>"31", 
                     "print_card" => "1", "work_phone"=>"", "date_of_birth(2i)"=>"1", "occupation"=>"engineer", "city"=>"Wilsonville", 
                     "cell_fax"=>"", "zip"=>"97070", "date_of_birth(3i)"=>"1", "mtb_category"=>"Spt", "dh_category"=>"", 
                     "member"=>"1", "gender"=>"M", "notes"=>"rm", "ccx_category"=>"", "team_name"=>"", "road_category"=>"5", 
                     "xc_number"=>"1061", "street"=>"31153 SW Willamette Hwy W", "track_category"=>"", "home_phone"=>"503-582-8823", 
                     "dh_number"=>"917", "road_number"=>"4051", "first_name"=>"Paul", "ccx_number"=>"112", "last_name"=>"Formiller", 
                     "date_of_birth(1i)"=>"1969", "email"=>"paul.formiller@verizon.net", "state"=>"OR", "ccx_only" => "1",
                     "official" => "1"
                    }, 
                   "id"=>molly.to_param}
    )
    assert(flash.empty?, "Expected flash.empty? but was: #{flash[:warn]}")
    assert_redirected_to edit_admin_person_path(molly)
    molly.reload
    assert_equal('222', molly.road_number(true, Time.zone.today.year), 'Road number should be updated')
    assert_equal(true, molly.print_card?, 'print_card?')
    assert_equal_dates('2004-02-16', molly.member_from, 'member_from after update')
    assert_equal_dates('2004-12-31', molly.member_to, 'member_to after update')
    assert_equal(true, molly.ccx_only?, 'ccx_only?')

    assert_equal 2, molly.versions.size, "versions"
    version = molly.versions.last
    assert_equal @administrator, version.user, "version user"
    changes = version.changes
    assert_equal 26, changes.size, "changes"
    change = changes["team_id"]
    assert_not_nil change, "Should have change for team ID"
    assert_equal vanilla.id, change.first, "Team ID before"
    assert_equal nil, change.last, "Team ID after"
    assert_equal @administrator, molly.updated_by, "updated_by"
  end
  
  def test_update_bad_member_from_date
    person = FactoryGirl.create(:person)
    put(:update, "commit"=>"Save", "person"=>{
                 "member_from(1i)"=>"","member_from(2i)"=>"10", "member_from(3i)"=>"19",  
                 "member_to(3i)"=>"31", "date_of_birth(2i)"=>"1", "city"=>"Hood River", 
                 "work_phone"=>"541-387-8883 x 213", "occupation"=>"Sales Territory Manager", "cell_fax"=>"541-387-8884",
                 "date_of_birth(3i)"=>"1", "zip"=>"97031", "license"=>"583", "mtb_category"=>"Beg",
                 "dh_category"=>"Beg", "notes"=>"interests: 6\r\nr\r\ninterests: 4\r\nr\r\ninterests: 4\r\n", "gender"=>"M", 
                 "ccx_category"=>"B", "team_name"=>"River City Specialized", "print_card"=>"1", 
                 "street"=>"3541 Avalon Drive", "home_phone"=>"503-367-5193", "road_category"=>"3", 
                 "track_category"=>"5", "first_name"=>"Karsten", "last_name"=>"Hagen", 
                 "member_to(1i)"=>"2008", "member_to(2i)"=>"12", "email"=>"khagen69@hotmail.com", "date_of_birth(1i)"=>"1969",  
                 "state"=>"OR"}, "number"=>{"30532"=>{"value"=>"1453"}, "30533"=>{"value"=>"373"}}, "id"=>person.to_param, 
                 "number_year"=>"2008"
    )
    assert_not_nil(assigns(:person), "@person")
    assert(assigns(:person).errors.empty?, "Should not have errors")
    assert(assigns(:person).errors[:member_from].empty?, "Should have no errors on 'member_from' but had #{assigns(:person).errors[:member_from]}")
    assert_redirected_to edit_admin_person_path(assigns(:person))
  end

  def test_number_year_changed
    person = FactoryGirl.create(:person)

    post(:number_year_changed, 
         :id => person.to_param.to_s,
         :year => '2010'
    )
    assert_response :success
    assert_template("admin/people/_numbers")
    assert_not_nil(assigns["race_numbers"], "Should assign 'race_numbers'")
    assert_not_nil(assigns["year"], "Should assign today's year as 'year'")
    assert_equal('2010', assigns["year"], "Should assign selected year as 'year'")
    assert_not_nil(assigns["years"], "Should assign range of years as 'years'")
    assert(assigns["years"].size >= 2, "Should assign range of years as 'years', but was: #{assigns[:years]}")
  end
  
  def test_one_print_card
    tonkin = FactoryGirl.create(:person)

    get(:card, :format => "pdf", :id => tonkin.to_param)

    assert_response :success
    assert_equal(tonkin, assigns['person'], 'Should assign person')
    tonkin.reload
    assert(!tonkin.print_card?, 'Tonkin.print_card? after printing')
  end
  
  def test_print_no_cards_pending
    get(:cards, :format => "pdf")
    assert_redirected_to(no_cards_admin_people_path(:format => "html"))
  end
  
  def test_no_cards
    get(:no_cards)
    assert_response :success
    assert_template("admin/people/no_cards")
    assert_layout("admin/application")
  end
  
  def test_print_cards
    tonkin = FactoryGirl.create(:person)
    tonkin.print_card = true
    tonkin.ccx_category = "Clydesdale"
    tonkin.mtb_category = "Beginner"
    tonkin.save!
    assert !tonkin.membership_card?, "Tonkin.membership_card? before printing"

    get(:cards, :format => "pdf")

    assert_response :success
    assert_template nil
    assert_layout(nil)
    assert_equal(1, assigns['people'].size, 'Should assign people')
    tonkin.reload
    assert(!tonkin.print_card?, 'Tonkin.print_card? after printing')
    assert tonkin.membership_card?, "Tonkin.has_card? after printing"
  end
  
  def test_many_print_cards
    people = []
    (1..4).each do |i|
      people << Person.create!(:first_name => 'First Name', :last_name => "Last #{i}", :print_card => true)
    end

    get(:cards, :format => "pdf")

    assert_response :success
    assert_template nil, "wrong template"
    assert_layout(nil)
    assert_equal(4, assigns['people'].size, 'Should assign people')
    people.each do |person|
      person.reload
      assert(!person.print_card?, 'Person.print_card? after printing')
      assert person.membership_card?, "person.membership_card? after printing"
    end
  end

  def test_edit_with_event
    kings_valley = FactoryGirl.create(:event)
    promoter = FactoryGirl.create(:person)
    get(:edit, :id => promoter.to_param, :event_id => kings_valley.to_param.to_s)
    assert_equal(promoter, assigns['person'], "Should assign 'person'")
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/people/edit")
  end

  def test_new_with_event
    kings_valley = FactoryGirl.create(:event)
    get(:new, :event_id => kings_valley.to_param)
    assert_not_nil(assigns['person'], "Should assign 'person'")
    assert(assigns['person'].new_record?, 'Promoter should be new record')
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/people/edit")
  end
  
  def test_remember_event_id_on_update
     promoter = FactoryGirl.create(:person)
     jack_frost = FactoryGirl.create(:event)

    put(:update, :id => promoter.id, 
      "person" => {"name" => "Fred Whatley", "home_phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, 
      "commit" => "Save",
      "event_id" => jack_frost.id)
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter.reload
    
    assert_redirected_to(edit_admin_person_path(promoter, :event_id => jack_frost))
  end
  
  def test_remember_event_id_on_create
    jack_frost = FactoryGirl.create(:event)
    post(:create, "person" => {"name" => "Fred Whatley", "home_phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, 
    "commit" => "Save",
    "event_id" => jack_frost.id)
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter = Person.find_by_name('Fred Whatley')
    assert_redirected_to(edit_admin_person_path(promoter, :event_id => jack_frost))
  end
end
