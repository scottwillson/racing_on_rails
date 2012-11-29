require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  module People
    class ImportTest < ActionController::TestCase
      tests Admin::PeopleController
      
      def setup
        super
        create_administrator_session
        use_ssl

        FactoryGirl.create(:discipline, :name => "Cyclocross")
        FactoryGirl.create(:discipline, :name => "Downhill")
        FactoryGirl.create(:discipline, :name => "Mountain Bike")
        FactoryGirl.create(:discipline, :name => "Road")
        FactoryGirl.create(:discipline, :name => "Singlespeed")
        FactoryGirl.create(:discipline, :name => "Track")
        FactoryGirl.create(:number_issuer)
      end
      
      def test_preview_import
        people_before_import = Person.count

        file = fixture_file_upload("../files/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv", "text/csv")
        post :preview_import, :people_file => file

        assert(!flash[:warn].present?, "flash[:warn] should be empty,  but was: #{flash[:warn]}")
        assert_response :success
        assert_template("admin/people/preview_import")
        assert_not_nil(assigns["people_file"], "Should assign 'people_file'")
        assert(session[:people_file_path].include?('55612_061202_151958.csv, attachment filename=55612_061202_151958.csv'), 
          'Should store temp file path in session as :people_file_path')
  
        assert_equal(people_before_import, Person.count, 'Should not have added people')
      end

      def test_preview_import_with_no_file
        post(:preview_import, :commit => 'Import', :people_file => "")

        assert(flash[:warn].present?, "should have flash[:warn]")
        assert_redirected_to admin_people_path
      end

      def test_import
        tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
        existing_duplicate = Duplicate.new(:new_attributes => Person.new(:name => 'Erik Tonkin').attributes)
        existing_duplicate.people << tonkin
        existing_duplicate.save!
        people_before_import = Person.count

        file = fixture_file_upload("../files/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv", "text/csv")
        @request.session[:people_file_path] = File.expand_path("#{::Rails.root.to_s}/test/files/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv")
        post(:import, :commit => 'Import', :update_membership => 'true')

        assert(!flash[:warn].present?, "flash[:warn] should be empty, but was: #{flash[:warn]}")
        assert(flash.notice.present?, "flash[:notice] should not be empty")
        assert_nil(session[:duplicates], 'session[:duplicates]')
        assert_redirected_to admin_people_path
  
        assert_nil(session[:people_file_path], 'Should remove temp file path from session')
        assert(people_before_import < Person.count, 'Should have added people')
        assert_equal(0, Duplicate.count, 'Should have no duplicates')
      end

      def test_import_next_year
        tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
        existing_duplicate = Duplicate.new(:new_attributes => Person.new(:name => 'Erik Tonkin').attributes)
        existing_duplicate.people << tonkin
        existing_duplicate.save!
        people_before_import = Person.count

        file = fixture_file_upload("../files/membership/database.xls", "application/vnd.ms-excel", :binary)
        @request.session[:people_file_path] = File.expand_path("#{::Rails.root.to_s}/test/files/membership/database.xls")
        next_year = Time.zone.today.year + 1
        post(:import, :commit => 'Import', :update_membership => 'true', :year => next_year)

        assert(!flash[:warn].present?, "flash[:warn] should be empty, but was: #{flash[:warn]}")
        assert(flash.notice.present?, "flash[:notice] should not be empty")
        assert_nil(session[:duplicates], 'session[:duplicates]')
        assert_redirected_to admin_people_path
  
        assert_nil(session[:people_file_path], 'Should remove temp file path from session')
        assert(people_before_import < Person.count, 'Should have added people')
        assert_equal(0, Duplicate.count, 'Should have no duplicates')
  
        rene = Person.find_by_name('Rene Babi')
        assert_not_nil(rene, 'Rene Babi should have been imported and created')
        road_number = rene.race_numbers.detect {|n| n.year == next_year && n.discipline == Discipline['road']}
        assert_not_nil(road_number, "Rene should have road number for #{next_year}")

        assert(rene.member?(Time.zone.today), 'Should be a member for this year')
        assert(rene.member?(Date.new(next_year - 1, 12, 31)), 'Should be a member for this year')
        assert(rene.member?(Date.new(next_year, 1, 1)), 'Should be a member for next year')

        heidi = Person.find_by_name('Heidi Babi')
        assert_not_nil(heidi, 'Heidi Babi should have been imported and created')
        assert(heidi.member?(Time.zone.today), 'Should be a member for this year')
        assert(heidi.member?(Date.new(next_year - 1, 12, 31)), 'Should be a member for this year')
        assert(heidi.member?(Date.new(next_year, 1, 1)), 'Should be a member for next year')
      end

      def test_import_with_duplicates
        FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
        FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
        people_before_import = Person.count

        file = fixture_file_upload("../files/membership/duplicates.xls", "application/vnd.ms-excel", :binary)
        @request.session[:people_file_path] = "#{::Rails.root.to_s}/test/files/membership/duplicates.xls"
        post(:import, :commit => 'Import', :update_membership => 'true')

        assert(flash[:warn].present?, "flash[:warn] should not be empty")
        assert(flash.notice.present?, "flash[:notice] should not be empty")
        assert_equal(1, Duplicate.count, 'Should have duplicates')
        assert_redirected_to duplicates_admin_people_path
  
        assert_nil(session[:people_file_path], 'Should remove temp file path from session')
        assert(people_before_import < Person.count, 'Should have added people')
      end

      def test_import_with_no_file
        post :import, :commit => 'Import', :update_membership => 'true'
        assert flash[:warn].present?, "should have flash[:warn]"
        assert_redirected_to admin_people_path
      end

      def test_duplicates
        @request.session[:duplicates] = []
        get(:duplicates)
        assert_response :success
        assert_template("admin/people/duplicates")
      end

      def test_resolve_duplicates
        FactoryGirl.create(:person, :first_name => "Alice", :last_name => "Pennington")
        
        FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
        Person.create!(:name => 'Erik Tonkin')
        
        FactoryGirl.create(:person, :first_name => "Ryan", :last_name => "Weaver")
        weaver_2 = Person.create!(:name => 'Ryan Weaver', :city => 'Kenton')
        weaver_3 = Person.create!(:name => 'Ryan Weaver', :city => 'Lake Oswego')
        alice_2 = Person.create!(:name => 'Alice Pennington', :road_category => '3')
        people_before_import = Person.count

        tonkin_dupe = Duplicate.create!(:new_attributes => {:name => 'Erik Tonkin'}, :people => Person.all( :conditions => ['last_name = ?', 'Tonkin']))
        ryan_dupe = Duplicate.create!(:new_attributes => {:name => 'Ryan Weaver', :city => 'Las Vegas'}, :people => Person.all( :conditions => ['last_name = ?', 'Weaver']))
        alice_dupe = Duplicate.create!(:new_attributes => {:name => 'Alice Pennington', :road_category => '2'}, :people => Person.all( :conditions => ['last_name = ?', 'Pennington']))
        post(:resolve_duplicates, tonkin_dupe.to_param => 'new', ryan_dupe.to_param => weaver_3.to_param, alice_dupe.to_param => alice_2.to_param)
        assert_redirected_to admin_people_path
        assert_equal(0, Duplicate.count, 'Should have no duplicates')
  
        assert_equal(3, Person.all( :conditions => ['last_name = ?', 'Tonkin']).size, 'Tonkins in database')
        assert_equal(3, Person.all( :conditions => ['last_name = ?', 'Weaver']).size, 'Weaver in database')
        assert_equal(2, Person.all( :conditions => ['last_name = ?', 'Pennington']).size, 'Pennington in database')
  
        weaver_3.reload
        assert_equal('Las Vegas', weaver_3.city, 'Weaver city')
  
        alice_2.reload
        assert_equal('2', alice_2.road_category, 'Alice category')
      end

      def test_cancel_import
        post(:import, :commit => 'Cancel', :update_membership => 'false')
        assert_redirected_to admin_people_path
        assert_nil(session[:people_file_path], 'Should remove temp file path from session')
      end
    end
  end
end

