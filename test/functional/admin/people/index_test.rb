require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  module People
    class IndexTest < ActionController::TestCase
      tests Admin::PeopleController

      def setup
        super
        create_administrator_session
        use_ssl
      end
    
      def test_not_logged_in_index
        destroy_person_session
        get(:index)
        assert_redirected_to new_person_session_url(secure_redirect_options)
        assert_nil(@request.session["person"], "No person in session")
      end

      def test_not_logged_in_edit
        destroy_person_session
        person = FactoryGirl.create(:person)
        get(:edit, :id => person.to_param)
        assert_nil(@request.session["person"], "No person in session")
        assert_redirected_to new_person_session_url(secure_redirect_options)
      end

      def test_index
        get(:index)
        assert_response :success
        assert_template("admin/people/index")
        assert_layout("admin/application")
        assert_not_nil(assigns["people"], "Should assign people")
        assert(assigns["people"].empty?, "Should have no people")
        assert_not_nil(assigns["name"], "Should assign name")
      end

      def test_find
        person = FactoryGirl.create(:person)
        get(:index, :name => 'weav')
        assert_response :success
        assert_template("admin/people/index")
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal([ person ], assigns['people'], 'Search for weav should find Weaver')
        assert_not_nil(assigns["name"], "Should assign name")
        assert_equal('weav', assigns['name'], "'name' assigns")
      end

      def test_find_by_number
        FactoryGirl.create(:discipline)
        FactoryGirl.create(:number_issuer)
        person = FactoryGirl.create(:person, :road_number => "777")
        get(:index, :name => '777')
        assert_response :success
        assert_template("admin/people/index")
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal([person], assigns['people'], 'Search for race number should find person')
        assert_not_nil(assigns["name"], "Should assign name")
        assert_equal('777', assigns['name'], "'name' assigns")
      end

      def test_find_nothing
        FactoryGirl.create(:person)
        get(:index, :name => 's7dfnacs89danfx')
        assert_response :success
        assert_template("admin/people/index")
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal(0, assigns['people'].size, "Should find no people")
      end

      def test_find_empty_name
        get(:index, :name => '')
        assert_response :success
        assert_template("admin/people/index")
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal(0, assigns['people'].size, "Search for '' should find no people")
        assert_not_nil(assigns["name"], "Should assign name")
        assert_equal('', assigns['name'], "'name' assigns")
      end

      def test_find_limit
        FactoryGirl.create_list(:person, 100)
        get(:index, :name => 'Ryan')
        assert_response :success
        assert_template("admin/people/index")
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal(RacingAssociation.current.search_results_limit, assigns['people'].size, "Search for '' should find all people")
        assert_not_nil(assigns["name"], "Should assign name")
        assert(!flash.empty?, 'flash not empty?')
        assert_equal('Ryan', assigns['name'], "'name' assigns")
      end

      def test_blank_name
        molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
        xhr :put, :update_attribute, 
            :id => molly.to_param,
            :name => "name",
            :value => ""
        assert_response :success
        person = assigns["person"]
        assert_equal molly, person, "@person"
        assert person.errors.empty?, "Should have no errors, but had: #{person.errors.full_messages.join(', ')}"
        molly.reload
        assert_equal "", molly.first_name, "Person first_name after update"
        assert_equal "", molly.last_name, "Person last_name after update"
      end

      def test_index_with_cookie
        FactoryGirl.create(:person)
        @request.cookies["person_name"] = "weaver"
        get(:index)
        assert_response :success
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal("weaver", assigns["name"], "Should assign name")
        assert_equal(1, assigns["people"].size, "Should have no people")
      end
    end
  end
end
