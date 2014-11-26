# coding: utf-8

require File.expand_path("../../../test_helper", __FILE__)

module Admin
  # :stopdoc:
  class PeopleControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl

      @cyclocross = FactoryGirl.create(:cyclocross_discipline)
      FactoryGirl.create(:discipline, name: "Downhill")
      @mountain_bike = FactoryGirl.create(:mtb_discipline)
      @road = FactoryGirl.create(:discipline, name: "Road")
      FactoryGirl.create(:discipline, name: "Singlespeed")
      FactoryGirl.create(:discipline, name: "Track")
      @association = FactoryGirl.create(:number_issuer)
    end

    test "toggle member" do
      molly = FactoryGirl.create(:person, first_name: "Molly", last_name: "Cameron")
      assert_equal(true, molly.member, 'member before update')
      post(:toggle_member, id: molly.to_param)
      assert_response :success
      assert_template("shared/_member")
      molly.reload
      assert_equal(false, molly.member, 'member after update')

      post(:toggle_member, id: molly.to_param)
      assert_response :success
      assert_template("shared/_member")
      molly.reload
      assert_equal(true, molly.member, 'member after second update')
    end

    test "new" do
      get(:new)
      assert_response :success
    end

    test "edit" do
      alice = FactoryGirl.create(:person)

      get(:edit, id: alice.to_param)
      assert_response :success
      assert_nil(assigns['event'], "Should not assign 'event'")
    end

    test "edit created by import file" do
      alice = FactoryGirl.create(:person)
      alice.updated_by = ImportFile.create!(name: "some_very_long_import_file_name.xls")
      alice.save!

      get(:edit, id: alice.to_param)
      assert_response :success
      assert_template("admin/people/edit")
      assert_not_nil(assigns["person"], "Should assign person")
      assert_equal(alice, assigns['person'], 'Should assign Alice to person')
    end

    test "create" do
      assert_equal([], Person.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')

      post(:create, {"person" => {
                          "member_from(1i)" => "", "member_from(2i)" => "", "member_from(3i)" => "",
                          "member_to(1i)" => "", "member_to(2i)" => "", "member_to(3i)" => "",
                          "date_of_birth(2i)" => "", "date_of_birth(1i)" => "", "date_of_birth(3i)" => "",
                          "work_phone" => "", "occupation" => "", "city" => "Brussels", "cell_fax" => "", "zip" => "",
                          "mtb_category" => "", "dh_category" => "", "member" => "1", "gender" => "", "ccx_category" => "",
                          "team_name" => "", "road_category" => "", "street" => "", "track_category" => "", "home_phone" => "",
                          "first_name" => "Jon", "last_name" => "Knowlson",
                          "email" => "", "state" => ""
                    }, "commit" => "Save"})

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

    test "update new number" do
      Timecop.freeze(Date.new(2008, 6)) do
        molly = FactoryGirl.create(:person, first_name: "Molly", last_name: "Cameron", road_number: "202")
        assert_equal('202', molly.road_number(true, 2008), 'Road number')
        assert_equal('202', molly.road_number(true), 'Road number')
        molly_road_number = RaceNumber.last
        year = Time.zone.today.year.to_s

        put(:update, {"commit" => "Save",
                       "number_year" => year,
                       "number_issuer_id" => [@association.to_param], "number_value" => ["AZY"],
                       "discipline_id" => [@mountain_bike.id.to_s],
                       "person" => {
                         "work_phone" => "", "date_of_birth(2i)" => "1", "occupation" => "engineer", "city" => "Wilsonville",
                         "cell_fax" => "", "zip" => "97070",
                         "date_of_birth(3i)" => "1", "mtb_category" => "Spt", "dh_category" => "",
                         "member" => "1", "gender" => "M", "notes" => "rm", "ccx_category" => "", "team_name" => "", "road_category" => "5",
                         "street" => "31153 SW Willamette Hwy W",
                         "track_category" => "", "home_phone" => "503-582-8823", "first_name" => "Paul", "last_name" => "Formiller",
                         "date_of_birth(1i)" => "1969",
                         "member_from(1i)" => "", "member_from(2i)" => "", "member_from(3i)" => "",
                         "member_to(1i)" => "", "member_to(2i)" => "", "member_to(3i)" => "",
                         "email" => "paul.formiller@verizon.net", "state" => "OR",
                         "race_numbers_attributes" => {
                           "0" => {"number_issuer_id" => @association.id, "discipline_id" => @road.id, "year" => year, "value" => "202", "id" => molly_road_number.to_param},
                           "1" => {"number_issuer_id" => @association.id, "discipline_id" => @mountain_bike.id, "year" => year, "value" => "AZY"}
                         }
                       },
                       "id" => molly.to_param}
        )
        assert assigns(:person).errors.empty?, assigns(:person).errors.full_messages.join(", ")
        assert(flash.empty?, "flash empty? but was: #{flash}")
        assert_redirected_to edit_admin_person_path(molly)
        molly.reload
        assert_equal('202', molly.road_number(true, 2008), 'Road number should not be updated')
        assert_equal('AZY', molly.xc_number(true, 2008), 'MTB number should be updated')
        assert_nil(molly.member_from, 'member_from after update')
        assert_nil(molly.member_to, 'member_to after update')
        assert_nil(RaceNumber.find(molly_road_number.to_param).updated_by_person, "updated_by_person")
        assert_equal(@administrator, RaceNumber.find_by_value("AZY").updated_by_person, "updated_by_person")
      end
    end

    test "create with empty password and no numbers" do
      post :create,  person: { login: "", password_confirmation: "", password: "", team_name: "",
                                  first_name: "Henry", last_name: "David", license: "" }, number_issuer_id: [ { "1" => nil } ]
      assert_not_nil assigns(:person), "@person"
      assert assigns(:person).errors.empty?, "Did no expect @person errors: #{assigns(:person).errors.full_messages.join(', ')}"
      assert_redirected_to edit_admin_person_path(assigns(:person))
    end

    test "update" do
      vanilla = FactoryGirl.create(:team)
      molly = FactoryGirl.create(:person, first_name: "Molly", last_name: "Cameron", road_number: "2", team: vanilla)
      Alias.create!(name: "Mollie Cameron", person: molly)
      FactoryGirl.create :result, person: molly, team: vanilla
      assert_equal 1, molly.versions.size, "versions"
      molly_road_number = RaceNumber.first

      put(:update, {"commit" => "Save",
                     "number_year" => Time.zone.today.year.to_s,
                     "person" => {
                       "member_from(1i)" => "2004", "member_from(2i)" => "2", "member_from(3i)" => "16",
                       "member_to(1i)" => "2004", "member_to(2i)" => "12", "member_to(3i)" => "31",
                       "print_card" => "1", "work_phone" => "", "date_of_birth(2i)" => "1", "occupation" => "engineer", "city" => "Wilsonville",
                       "cell_fax" => "", "zip" => "97070", "date_of_birth(3i)" => "1", "mtb_category" => "Spt", "dh_category" => "",
                       "member" => "1", "gender" => "M", "notes" => "rm", "ccx_category" => "", "team_name" => "", "road_category" => "5",
                       "street" => "31153 SW Willamette Hwy W", "track_category" => "", "home_phone" => "503-582-8823",
                       "first_name" => "Paul", "last_name" => "Formiller",
                       "date_of_birth(1i)" => "1969", "email" => "paul.formiller@verizon.net", "state" => "OR", "ccx_only" => "1",
                       "official" => "1",
                       "race_numbers_attributes" => {
                         "0" => { "value" => "222", "id" => molly_road_number.id },
                         "1" => { "number_issuer_id" => @association.to_param, "discipline_id" => @cyclocross.id, "year" => Time.zone.today.year.to_s }
                       }
                      },
                     "id" => molly.to_param}
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
      assert_equal @administrator, molly.updated_by_person, "updated_by_person"
    end

    test "update bad member from date" do
      person = FactoryGirl.create(:person)
      put(:update, "commit" => "Save", "person" => {
                   "member_from(1i)" => "","member_from(2i)" => "10", "member_from(3i)" => "19",
                   "member_to(3i)" => "31", "date_of_birth(2i)" => "1", "city" => "Hood River",
                   "work_phone" => "541-387-8883 x 213", "occupation" => "Sales Territory Manager", "cell_fax" => "541-387-8884",
                   "date_of_birth(3i)" => "1", "zip" => "97031", "license" => "583", "mtb_category" => "Beg",
                   "dh_category" => "Beg", "notes" => "interests: 6\r\nr\r\ninterests: 4\r\nr\r\ninterests: 4\r\n", "gender" => "M",
                   "ccx_category" => "B", "team_name" => "River City Specialized", "print_card" => "1",
                   "street" => "3541 Avalon Drive", "home_phone" => "503-367-5193", "road_category" => "3",
                   "track_category" => "5", "first_name" => "Karsten", "last_name" => "Hagen",
                   "member_to(1i)" => "2008", "member_to(2i)" => "12", "email" => "khagen69@hotmail.com", "date_of_birth(1i)" => "1969",
                   "state" => "OR"}, "id" => person.to_param,
                   "number_year" => "2008"
      )
      assert_not_nil(assigns(:person), "@person")
      assert(assigns(:person).errors.empty?, "Should not have errors")
      assert(assigns(:person).errors[:member_from].empty?, "Should have no errors on 'member_from' but had #{assigns(:person).errors[:member_from]}")
      assert_redirected_to edit_admin_person_path(assigns(:person))
    end

    test "one print card" do
      tonkin = FactoryGirl.create(:person)

      get(:card, format: "pdf", id: tonkin.to_param)

      assert_response :success
      assert_equal(tonkin, assigns['person'], 'Should assign person')
      tonkin.reload
      assert(!tonkin.print_card?, 'Tonkin.print_card? after printing')
    end

    test "print no cards pending" do
      get(:cards, format: "pdf")
      assert_redirected_to(no_cards_admin_people_path(format: "html"))
    end

    test "no cards" do
      get(:no_cards)
      assert_response :success
      assert_template("admin/people/no_cards")
      assert_template layout: "admin/application"
    end

    test "print cards" do
      tonkin = FactoryGirl.create(:person)
      tonkin.print_card = true
      tonkin.ccx_category = "Clydesdale"
      tonkin.mtb_category = "Beginner"
      tonkin.save!
      assert !tonkin.membership_card?, "Tonkin.membership_card? before printing"

      get(:cards, format: "pdf")

      assert_response :success
      assert_template nil
      assert_template layout: nil
      assert_equal(1, assigns['people'].size, 'Should assign people')
      tonkin.reload
      assert(!tonkin.print_card?, 'Tonkin.print_card? after printing')
      assert tonkin.membership_card?, "Tonkin.has_card? after printing"
    end

    test "many print cards" do
      people = []
      (1..4).each do |i|
        people << Person.create!(first_name: 'First Name', last_name: "Last #{i}", print_card: true)
      end

      get(:cards, format: "pdf")

      assert_response :success
      assert_template nil, "wrong template"
      assert_template layout: nil
      assert_equal(4, assigns['people'].size, 'Should assign people')
      people.each do |person|
        person.reload
        assert(!person.print_card?, 'Person.print_card? after printing')
        assert person.membership_card?, "person.membership_card? after printing"
      end
    end

    test "edit with event" do
      kings_valley = FactoryGirl.create(:event)
      promoter = FactoryGirl.create(:person)
      get(:edit, id: promoter.to_param, event_id: kings_valley.to_param.to_s)
      assert_equal(promoter, assigns['person'], "Should assign 'person'")
      assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
      assert_template("admin/people/edit")
    end

    test "new with event" do
      kings_valley = FactoryGirl.create(:event)
      get(:new, event_id: kings_valley.to_param)
      assert_not_nil(assigns['person'], "Should assign 'person'")
      assert(assigns['person'].new_record?, 'Promoter should be new record')
      assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
      assert_template("admin/people/edit")
    end

    test "remember event id on update" do
       promoter = FactoryGirl.create(:person)
       jack_frost = FactoryGirl.create(:event)

      put(:update, id: promoter.id,
        "person" => {"home_phone" => "(510) 410-2201", "email" => "fred@whatley.net"},
        "commit" => "Save",
        "event_id" => jack_frost.id)

      assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")

      promoter.reload

      assert_redirected_to(edit_admin_person_path(promoter, event_id: jack_frost))
    end

    test "remember event id on create" do
      jack_frost = FactoryGirl.create(:event)
      post(
        :create,
        "person" => {"first_name" => "Fred", "last_name" => "Whatley", "home_phone" => "(510) 410-2201", "email" => "fred@whatley.net"},
        "commit" => "Save",
        "event_id" => jack_frost.id
      )

      assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")

      promoter = Person.find_by_name('Fred Whatley')
      assert_redirected_to(edit_admin_person_path(promoter, event_id: jack_frost))
    end

    test "destroy" do
      person = FactoryGirl.create(:person)
      delete :destroy, id: person.id
      assert !Person.exists?(person)
      assert_redirected_to admin_people_path
      assert flash.notice.present?
    end

    test "cannot destroy" do
      result = FactoryGirl.create(:result)
      person = result.person
      delete :destroy, id: person.id
      assert Person.exists?(person)
      assert_response :success
      assert flash[:warn].present?
    end
  end
end
