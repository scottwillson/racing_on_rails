require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  module People
    class MergeTest < ActionController::TestCase
      tests Admin::PeopleController
      
      def setup
        super
        create_administrator_session
        use_ssl
      end

      def test_merge?
        molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
        tonkin = FactoryGirl.create(:person)
        xhr :put, :update_attribute, 
            :id => tonkin.to_param,
            :name => "name",
            :value => molly.name
        assert_response :success
        assert_equal(tonkin, assigns['person'], 'Person')
        person = assigns['person']
        assert(person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages.join(', ')}")
        assert_template("admin/people/merge_confirm")
        assert_equal(molly.name, assigns['person'].name, 'Unsaved Tonkin name should be Molly')
        assert_equal([molly], assigns['other_people'], 'other_people')
      end

      def test_merge
        molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
        tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
        old_id = tonkin.id
        assert Person.find_all_by_name("Erik Tonkin"), "Tonkin should be in database"

        xhr :post, :merge, :other_person_id => tonkin.to_param, :id => molly.to_param, :format => :js
        assert_response :success
        assert_template "admin/people/merge"

        assert Person.find_all_by_name("Molly Cameron"), "Molly should be in database"
        assert_equal [], Person.find_all_by_name("Erik Tonkin"), "Tonkin should not be in database"
      end

      def test_dupes_merge?
        FactoryGirl.create(:discipline)
        FactoryGirl.create(:number_issuer)
        
        molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
        molly_with_different_road_number = Person.create(:name => 'Molly Cameron', :road_number => '987123')
        tonkin = FactoryGirl.create(:person)
        xhr :put, :update_attribute, 
            :id => tonkin.to_param,
            :name => "name",
            :value => molly.name
        assert_response :success
        assert_equal tonkin, assigns['person'], 'Person'
        person = assigns['person']
        assert person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages.join(', ')}"
        assert_template "admin/people/merge_confirm", "template"
        assert_equal(molly.name, assigns['person'].name, 'Unsaved Tonkin name should be Molly')
        other_people = assigns['other_people'].sort {|x, y| x.id <=> y.id}
        assert_equal([molly, molly_with_different_road_number], other_people, 'other_people')
      end

      def test_dupes_merge_one_has_road_number_one_has_cross_number?
        FactoryGirl.create(:discipline)
        FactoryGirl.create(:cyclocross_discipline)
        FactoryGirl.create(:number_issuer)

        molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
        molly.ccx_number = '102'
        molly.save!
        molly_with_different_cross_number = Person.create(:name => 'Molly Cameron', :ccx_number => '810', :road_number => '1009')
        tonkin = FactoryGirl.create(:person)
        xhr :put, :update_attribute, 
            :id => tonkin.to_param,
            :name => "name",
            :value => molly.name
        assert_response :success
        assert_equal(tonkin, assigns['person'], 'Person')
        person = assigns['person']
        assert(person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages.join(', ')}")
        assert_template("admin/people/merge_confirm")
        assert_equal(molly.name, assigns['person'].name, 'Unsaved Tonkin name should be Molly')
        other_people = assigns['other_people'].collect do |p|
          "#{p.name} ##{p.id}"
        end
        other_people = other_people.join(', ')
        assert(assigns['other_people'].include?(molly), "other_people should include Molly ##{molly.id}, but has #{other_people}")
        assert(assigns['other_people'].include?(molly_with_different_cross_number), 'other_people')
        assert_equal(2, assigns['other_people'].size, 'other_people')
      end

      def test_dupes_merge_alias?
        molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
        tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
        tonkin.aliases.create!(:name => "Eric Tonkin")
        
        xhr :put, :update_attribute, 
            :id => molly.to_param,
            :name => "name",
            :value => "Eric Tonkin"
        assert_response :success, "success response"
        assert_equal(molly, assigns['person'], 'Person')
        person = assigns['person']
        assert(person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages.join(', ')}")
        assert_equal('Eric Tonkin', assigns['person'].name, 'Unsaved Molly name should be Eric Tonkin alias')
        assert_equal([tonkin], assigns['other_people'], 'other_peoples')
      end

      def test_dupe_merge
        FactoryGirl.create(:discipline)
        FactoryGirl.create(:number_issuer)

        molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
        tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
        tonkin_with_different_road_number = Person.create(:name => 'Erik Tonkin', :road_number => 'YYZ')
        assert(tonkin_with_different_road_number.valid?, "tonkin_with_different_road_number not valid: #{tonkin_with_different_road_number.errors.full_messages.join(', ')}")
        assert_equal(tonkin_with_different_road_number.new_record?, false, 'tonkin_with_different_road_number should be saved')
        old_id = tonkin.id
        assert_equal(2, Person.find_all_by_name('Erik Tonkin').size, 'Tonkins in database')

        post :merge, :id => molly.id, :other_person_id => tonkin.to_param, :format => :js
        assert_response :success
        assert_template("admin/people/merge")

        assert(Person.find_all_by_name('Molly Cameron'), 'Molly should be in database')
        tonkins_after_merge = Person.find_all_by_name('Erik Tonkin')
        assert_equal(1, tonkins_after_merge.size, tonkins_after_merge)
      end
    end
  end
end

