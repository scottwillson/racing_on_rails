# frozen_string_literal: true

require File.expand_path("../../../test_helper", __dir__)

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

      test "merge?" do
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        tonkin = FactoryBot.create(:person)
        put :update_attribute,
            params: {
              id: tonkin.to_param,
              name: "name",
              value: molly.name
            },
            xhr: true
        assert_response :success
        assert_equal(tonkin, assigns["person"], "Person")
        person = assigns["person"]
        assert(person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages.join(', ')}")
        assert_template("admin/people/merge_confirm")
        assert_equal(molly.name, assigns["person"].name, "Unsaved Tonkin name should be Molly")
        assert_equal([molly], assigns["other_people"], "other_people")
      end

      test "merge" do
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
        assert Person.find_all_by_name("Erik Tonkin"), "Tonkin should be in database"

        post :merge, params: { other_person_id: tonkin.to_param, id: molly.to_param }, xhr: true, format: :js
        assert_response :success
        assert_template "admin/people/merge"

        assert Person.find_all_by_name("Molly Cameron"), "Molly should be in database"
        assert_equal [], Person.find_all_by_name("Erik Tonkin"), "Tonkin should not be in database"
      end

      test "merge same person" do
        tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
        assert Person.find_all_by_name("Erik Tonkin"), "Tonkin should be in database"

        post :merge, params: { other_person_id: tonkin.to_param, id: tonkin.to_param }, xhr: true, format: :js
        assert_response :success
        assert_template "admin/people/merge"

        assert Person.find_all_by_name("Erik Tonkin"), "Tonkin should be in database"
      end

      test "dupes merge?" do
        FactoryBot.create(:discipline)
        FactoryBot.create(:number_issuer)

        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        molly_with_different_road_number = Person.create(name: "Molly Cameron", road_number: "987123")
        tonkin = FactoryBot.create(:person)
        put :update_attribute,
            params: {
              id: tonkin.to_param,
              name: "name",
              value: molly.name
            },
            xhr: true
        assert_response :success
        assert_equal tonkin, assigns["person"], "Person"
        person = assigns["person"]
        assert person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages.join(', ')}"
        assert_template "admin/people/merge_confirm", "template"
        assert_equal(molly.name, assigns["person"].name, "Unsaved Tonkin name should be Molly")
        other_people = assigns["other_people"].sort_by(&:id)
        assert_equal([molly, molly_with_different_road_number], other_people, "other_people")
      end

      test "dupes merge one has road number one has cross number?" do
        FactoryBot.create(:discipline)
        FactoryBot.create(:cyclocross_discipline)
        FactoryBot.create(:number_issuer)

        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        molly.ccx_number = "102"
        molly.save!
        molly_with_different_cross_number = Person.create(name: "Molly Cameron", ccx_number: "810", road_number: "1009")
        tonkin = FactoryBot.create(:person)
        put :update_attribute,
            params: {
              id: tonkin.to_param,
              name: "name",
              value: molly.name
            },
            xhr: true
        assert_response :success
        assert_equal(tonkin, assigns["person"], "Person")
        person = assigns["person"]
        assert(person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages.join(', ')}")
        assert_template("admin/people/merge_confirm")
        assert_equal(molly.name, assigns["person"].name, "Unsaved Tonkin name should be Molly")
        other_people = assigns["other_people"].collect do |p|
          "#{p.name} ##{p.id}"
        end
        other_people = other_people.join(", ")
        assert(assigns["other_people"].include?(molly), "other_people should include Molly ##{molly.id}, but has #{other_people}")
        assert(assigns["other_people"].include?(molly_with_different_cross_number), "other_people")
        assert_equal(2, assigns["other_people"].size, "other_people")
      end

      test "dupes merge alias?" do
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
        tonkin.aliases.create!(name: "Eric Tonkin")

        put :update_attribute,
            params: {
              id: molly.to_param,
              name: "name",
              value: "Eric Tonkin"
            },
            xhr: true
        assert_response :success, "success response"
        assert_equal(molly, assigns["person"], "Person")
        person = assigns["person"]
        assert(person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages.join(', ')}")
        assert_equal("Eric Tonkin", assigns["person"].name, "Unsaved Molly name should be Eric Tonkin alias")
        assert_equal([tonkin], assigns["other_people"], "other_peoples")
      end

      test "dupe merge" do
        FactoryBot.create(:discipline)
        FactoryBot.create(:number_issuer)

        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
        tonkin_with_different_road_number = Person.create(name: "Erik Tonkin", road_number: "YYZ")
        assert(tonkin_with_different_road_number.valid?, "tonkin_with_different_road_number not valid: #{tonkin_with_different_road_number.errors.full_messages.join(', ')}")
        assert_equal(tonkin_with_different_road_number.new_record?, false, "tonkin_with_different_road_number should be saved")
        assert_equal(2, Person.find_all_by_name("Erik Tonkin").size, "Tonkins in database")

        post :merge, params: { id: molly.id, other_person_id: tonkin.to_param }, format: :js
        assert_response :success
        assert_template("admin/people/merge")

        assert(Person.find_all_by_name("Molly Cameron"), "Molly should be in database")
        tonkins_after_merge = Person.find_all_by_name("Erik Tonkin")
        assert_equal(1, tonkins_after_merge.size, tonkins_after_merge)
      end
    end
  end
end
