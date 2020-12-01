# frozen_string_literal: true

require File.expand_path("../../../test_helper", __dir__)

# :stopdoc:
module Admin
  module People
    class UpdateNameTest < ActionController::TestCase
      tests Admin::PeopleController

      def setup
        super
        create_administrator_session
        use_ssl
      end

      test "update name" do
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        put :update_attribute,
            xhr: true,
            params: {
              id: molly.to_param,
              name: "name",
              value: "Mollie Cameron"
            }
        assert_response :success
        assert @response.body["Mollie Cameron"]
        molly.reload
        assert_equal "Mollie", molly.first_name, "Person first_name after update"
        assert_equal "Cameron", molly.last_name, "Person last_name after update"
      end

      test "update same name" do
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        put :update_attribute,
            xhr: true,
            params: {
              id: molly.to_param,
              name: "name",
              value: "Molly Cameron"
            }
        assert_response :success
        assert_not_nil(assigns["person"], "Should assign person")
        assert_equal(molly, assigns["person"], "Person")
        molly.reload
        assert_equal("Molly", molly.first_name, "Person first_name after update")
        assert_equal("Cameron", molly.last_name, "Person last_name after update")
      end

      test "update same name different case" do
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        put :update_attribute,
            xhr: true,
            params: {
              id: molly.to_param,
              name: "name",
              value: "molly cameron"
            }
        assert_response :success
        assert_not_nil(assigns["person"], "Should assign person")
        assert_equal(molly, assigns["person"], "Person")
        molly.reload
        assert_equal("molly", molly.first_name, "Person first_name after update")
        assert_equal("cameron", molly.last_name, "Person last_name after update")
      end

      test "update to existing name" do
        # Should ask to merge
        FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        put :update_attribute,
            xhr: true,
            params: {
              id: molly.to_param,
              name: "name",
              value: "Erik Tonkin"
            }
        assert_response :success
        assert_template("admin/people/merge_confirm")
        assert_not_nil(assigns["person"], "Should assign person")
        assert_equal(molly, assigns["person"], "Person")
        assert_not_nil(Person.find_all_by_name("Molly Cameron"), "Molly still in database")
        assert_not_nil(Person.find_all_by_name("Erik Tonkin"), "Tonkin still in database")
        molly.reload
        assert_equal("Molly Cameron", molly.name, "Person name after cancel")
      end

      test "update to existing alias" do
        tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
        tonkin.aliases.create!(name: "Eric Tonkin")

        put :update_attribute,
            params: {
              id: tonkin.to_param,
              name: "name",
              value: "Eric Tonkin"
            },
            xhr: true
        assert_response :success
        assert_not_nil(assigns["person"], "Should assign person")
        assert_equal(tonkin, assigns["person"], "Person")
        tonkin.reload
        assert_equal("Eric Tonkin", tonkin.name, "Person name")
        erik_alias = Alias.find_by(name: "Erik Tonkin")
        assert_not_nil(erik_alias, "Alias")
        assert_equal(tonkin, erik_alias.person, "Alias person")
        old_erik_alias = Alias.find_by(name: "Eric Tonkin")
        assert_nil(old_erik_alias, "Old alias")
      end

      test "update to existing alias different case" do
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        molly.aliases.create!(name: "Mollie Cameron")
        assert_not Alias.exists?(name: "Molly Cameron")

        put :update_attribute,
            params: {
              id: molly.to_param,
              name: "name",
              value: "mollie cameron"
            },
            xhr: true
        assert_response :success
        assert_not_nil(assigns["person"], "Should assign person")
        assert_equal(molly, assigns["person"], "Person")
        molly.reload
        assert_equal("mollie cameron", molly.name, "Person name after update")
        molly_alias = Alias.find_by(name: "Molly Cameron")
        assert_not_nil(molly_alias, "Alias")
        assert_equal(molly, molly_alias.person, "Alias person")
        mollie_alias = Alias.find_by(name: "mollie cameron")
        assert_nil(mollie_alias, "Alias")
      end

      test "update to other person existing alias" do
        tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        molly.aliases.create!(name: "Mollie Cameron")

        put :update_attribute,
            params: {
              id: tonkin.to_param,
              name: "name",
              value: "Mollie Cameron"
            },
            xhr: true
        assert_response :success
        assert_template("admin/people/merge_confirm")
        assert_not_nil(assigns["person"], "Should assign person")
        assert_equal(tonkin, assigns["person"], "Person")
        assert_equal([molly], assigns["other_people"], "other_people")
        assert_not(Alias.find_all_people_by_name("Mollie Cameron").empty?, "Mollie still in database")
        assert_not(Person.find_all_by_name("Molly Cameron").empty?, "Molly still in database")
        assert_not(Person.find_all_by_name("Erik Tonkin").empty?, "Erik Tonkin still in database")
      end

      test "update to other person existing alias and duplicate names" do
        FactoryBot.create(:discipline)
        FactoryBot.create(:number_issuer)

        tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
        # Molly with different road number
        Person.create!(name: "Molly Cameron", road_number: "1009")
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        molly.aliases.create!(name: "Mollie Cameron")

        assert_equal 0, Person.where(first_name: "Mollie", last_name: "Cameron").count, "Mollies in database"
        assert_equal 2, Person.where(first_name: "Molly", last_name: "Cameron").count, "Mollys in database"
        assert_equal 1, Person.where(first_name: "Erik", last_name: "Tonkin").count, "Eriks in database"
        assert_equal 1, Alias.where(name: "Mollie Cameron").count, "Mollie aliases in database"

        put :update_attribute,
            params: {
              id: tonkin.to_param,
              name: "name",
              value: "Mollie Cameron"
            },
            xhr: true
        assert_response :success
        assert_template("admin/people/merge_confirm")
        assert_not_nil(assigns["person"], "Should assign person")
        assert_equal(tonkin, assigns["person"], "Person")
        assert_equal(1, assigns["other_people"].size, "other_people: #{assigns['other_people']}")

        assert_equal 0, Person.where(first_name: "Mollie", last_name: "Cameron").count, "Mollies in database"
        assert_equal 2, Person.where(first_name: "Molly", last_name: "Cameron").count, "Mollys in database"
        assert_equal 1, Person.where(first_name: "Erik", last_name: "Tonkin").count, "Eriks in database"
        assert_equal 1, Alias.where(name: "Mollie Cameron").count, "Mollie aliases in database"
      end
    end
  end
end
