# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class PersonTest < ActiveSupport::TestCase
  test "save" do
    assert !Person.exists?(last_name: "Hampsten"), "Hampsten should not be in DB"
    assert !Team.exists?(name: "7-11"), "7-11 should not be in DB"

    person = Person.new(last_name: "Hampsten")
    team = Team.new(name: "7-11")

    person.team = team
    admin = FactoryBot.create(:administrator)
    Person.current = admin
    assert_nil person.created_by_name, "created_by_name"
    assert_nil person.updated_by_name, "updated_by_name"
    assert_nil person.created_by_type, "created_by_type"
    assert_nil person.updated_by_type, "updated_by_type"

    person.save!
    person.reload

    assert Team.exists?(name: "7-11"), "7-11 should be in DB"
    assert_equal person.team, person.team, "person.team"

    assert_equal "Candi Murray", person.created_by_name, "created_by_name"
    assert_equal "Candi Murray", person.updated_by_name, "updated_by_name"
    assert_equal admin, person.updated_by, "updated_by"
    assert_nil person.updater, "updater"

    assert_equal 1, person.versions.size, "Should create initial version"
    assert_equal "Candi Murray", person.created_by_name, "created_by_name"
    assert_equal "Candi Murray", person.updated_by_name, "updated_by_name"
    assert_equal "Person", person.created_by_type, "created_by_type"
    assert_equal "Person", person.updated_by_type, "updated_by_type"

    another_admin = FactoryBot.create(:person)
    Person.current = another_admin
    person.update! city: "Boulder"
    person.reload

    assert_equal 2, person.versions.size, "Should create second version after update"
    assert_equal another_admin, person.updated_by, "updated_by"
    assert_equal "Candi Murray", person.created_by_name, "created_by_name"
    assert_equal another_admin.name, person.updated_by_name, "updated_by_name"
    assert_equal "Person", person.created_by_type, "created_by_type"
    assert_equal "Person", person.updated_by_type, "updated_by_type"

    file = ImportFile.create!(name: "/tmp/import.xls")
    person.update!(name: "Andrew Hampsten", updater: file)
    assert_equal "Candi Murray", person.created_by_name, "created_by_name"
    assert_equal "/tmp/import.xls", person.updated_by_name, "updated_by_name"
    assert_equal "Person", person.created_by_type, "created_by_type"
    assert_equal "ImportFile", person.updated_by_type, "updated_by_type"
  end

  test "save existing team" do
    assert_nil(Person.find_by(last_name: "Hampsten"), "Hampsten should not be in DB")
    FactoryBot.create(:team, name: "Vanilla").aliases.create!(name: "Vanilla Bicycles")
    assert_not_nil(Team.find_by(name: "Vanilla"), "Vanilla should be in DB")

    person = Person.new(last_name: "Hampsten")
    team = Team.new(name: "Vanilla")

    person.team = team
    person.save!
    assert_equal(person.team, Team.find_by(name: "Vanilla"), "Vanilla from DB")
    person.reload
    assert_equal(person.team, Team.find_by(name: "Vanilla"), "Vanilla from DB")
  end

  test "team name should preserve aliases" do
    team = Team.create!(name: "Sorella Forte Elite Team")
    event = SingleDayEvent.create!(date: 1.year.ago)
    senior_men = FactoryBot.create(:category)
    event.races.create!(category: senior_men).results.create!(team: team)
    team.aliases.create!(name: "Sorella Forte")
    assert_equal(0, team.names.reload.size, "names")
    assert_equal(1, team.aliases.reload.size, "Aliases")
    assert_equal(["Sorella Forte"], team.aliases.map(&:name).sort, "Team aliases")

    person = Person.new(name: "New Person", team_name: "Sorella Forte")
    person.save!

    assert_equal(1, Team.where(name: "Sorella Forte Elite Team").count, "Should have one Sorella Forte in database")
    team = Team.find_by(name: "Sorella Forte Elite Team")
    assert_equal(0, team.names.reload.size, "names")
    assert_equal(1, team.aliases.reload.size, "Aliases")
    assert_equal(["Sorella Forte"], team.aliases.map(&:name).sort, "Team aliases")
  end

  test "do not merge other people with same name" do
    person_1 = FactoryBot.create(:person, name: "Molly Cameron", other_people_with_same_name: true)
    person_2 = FactoryBot.create(:person, name: "Molly Cameron")

    assert !person_1.merge(person_2)
    assert !person_2.merge(person_1)
    assert !person_1.merge?(person_2)
    assert !person_2.merge?(person_1)
  end

  test "merge" do
    FactoryBot.create(:number_issuer)
    FactoryBot.create(:discipline, name: "Road")

    person_to_keep = FactoryBot.create(
      :person_with_login,
      login: "molly",
      city: "Berlin",
      state: "CT",
      road_number: "202",
      member_from: Time.zone.local(1996),
      membership_address_is_billing_address: false,
      official_interest: false,
      created_at: 1.week.ago,
      print_card: true,
      race_promotion_interest: true,
      team: nil
    )
    person_to_keep.aliases.create!(name: "Mollie Cameron")
    person_to_keep_old_password = person_to_keep.crypted_password
    FactoryBot.create(:result, person: person_to_keep)
    FactoryBot.create(:result, person: person_to_keep)
    FactoryBot.create(:result, person: person_to_keep)
    event_team_membership = FactoryBot.create(:event_team_membership, person: person_to_keep)

    team = FactoryBot.create(:team, name: "Gentle Lovers")
    person_to_merge = FactoryBot.create(
      :person,
      member_to: Time.zone.local(2008, 12, 31),
      city: "Middletown",
      license: "7123811",
      membership_address_is_billing_address: false,
      official_interest: true,
      print_card: false,
      race_promotion_interest: true,
      team: team
    )
    person_to_merge.race_numbers.create!(value: "102")
    person_to_merge.race_numbers.create!(year: 2004, value: "104")
    FactoryBot.create(:result, person: person_to_merge)
    FactoryBot.create(:result, person: person_to_merge)
    person_to_merge.aliases.create!(name: "Eric Tonkin")
    FactoryBot.create(:event_team_membership, person: person_to_merge, event_team: event_team_membership.event_team)

    assert Person.where(first_name: person_to_keep.first_name, last_name: person_to_keep.last_name).exists?, "#{person_to_keep.name} should be in DB"
    assert_equal(3, Result.where(person_id: person_to_keep.id).count, "Molly's results")
    assert_equal(1, Alias.where(aliasable_id: person_to_keep.id).count, "Mollys's aliases")
    assert_equal(1, person_to_keep.race_numbers.count, "Target person's race numbers")
    assert_equal("202", person_to_keep.race_numbers.first.value, "Target person's race number value")
    association = NumberIssuer.find_by(name: RacingAssociation.current.short_name)
    assert_equal(association, person_to_keep.race_numbers.first.number_issuer, "Target person's race number issuer")

    assert Person.where(first_name: person_to_merge.first_name, last_name: person_to_merge.last_name).exists?, "#{person_to_merge.name} should be in DB"
    assert_equal(2, Result.where(person_id: person_to_merge.id).count, "Tonkin's results")
    assert_equal(1, Alias.where(aliasable_id: person_to_merge.id).count, "Tonkin's aliases")
    assert_equal(2, person_to_merge.race_numbers.count, "Merging person's race numbers")
    race_numbers = person_to_merge.race_numbers.sort
    assert_equal("102", race_numbers.first.value, "Merging person's race number value")
    assert_equal(association, race_numbers.first.number_issuer, "Merging person's race number issuer")
    assert_equal("104", race_numbers.last.value, "Merging person's race number value")
    elkhorn = NumberIssuer.create!(name: "Elkhorn")
    race_numbers.last.number_issuer = elkhorn
    race_numbers.last.save!
    assert_equal(elkhorn, race_numbers.last.number_issuer, "Merging person's race number issuer")

    promoter_events = [Event.create!(promoter: person_to_keep), Event.create!(promoter: person_to_merge)]

    person_to_keep.reload
    person_to_merge.reload
    person_to_keep.merge(person_to_merge)

    person_to_keep.reload
    assert Person.where(first_name: person_to_keep.first_name, last_name: person_to_keep.last_name).exists?, "#{person_to_keep.name} should be in DB"
    assert_equal(5, Result.where(person_id: person_to_keep.id).count, "Molly's results")
    aliases = Alias.where(aliasable_id: person_to_keep.id)
    erik_alias = aliases.detect { |a| a.name == person_to_merge.name }
    assert_not_nil(erik_alias, "Molly should have merged person's name as an alias")
    assert_equal(3, Alias.where(aliasable_id: person_to_keep.id).count, "Molly's aliases")
    assert_equal(3, person_to_keep.race_numbers.reload.size, "Target person's race numbers: #{person_to_keep.race_numbers.map(&:value)}")
    race_numbers = person_to_keep.race_numbers.sort
    assert_equal("102", race_numbers[0].value, "Person's race number value")
    assert_equal(association, race_numbers[0].number_issuer, "Person's race number issuer")
    assert_equal("104", race_numbers[1].value, "Person's race number value")
    assert_equal(elkhorn, race_numbers[1].number_issuer, "Person's race number issuer")
    assert_equal("202", race_numbers[2].value, "Person's race number value")
    assert_equal(association, race_numbers[2].number_issuer, "Person's race number issuer")

    assert !Person.where(first_name: person_to_merge.first_name, last_name: person_to_merge.last_name).exists?, "#{person_to_merge.name} should not be in DB"
    assert_equal(0, Result.where(person_id: person_to_merge.id).count, "Tonkin's results")
    assert_equal(0, Alias.where(aliasable_id: person_to_merge.id).count, "Tonkin's aliases")
    assert_same_elements(promoter_events, person_to_keep.events.reload, "Should merge promoter events")

    assert_equal "molly", person_to_keep.login, "Should preserve login"
    assert_equal person_to_keep_old_password, person_to_keep.crypted_password, "Should preserve password"

    assert_equal_dates Time.zone.local(1996).to_date, person_to_keep.member_from, "member_from"
    assert_equal_dates Time.zone.now.end_of_year.to_date, person_to_keep.member_to, "member_to"

    assert_equal "7123811", person_to_keep.license, "license"
    assert_equal "Middletown", person_to_keep.city, "should update city from newer person to merge"
    assert_equal "CT", person_to_keep.state, "should preserve state in person to keep"
    assert_equal false, person_to_keep.membership_address_is_billing_address, "should preserve booleans in person to keep"
    assert_equal false, person_to_keep.official_interest, "should preserve booleans in person to keep"
    assert_equal true, person_to_keep.print_card, "should preserve booleans in person to keep"
    assert_equal true, person_to_keep.race_promotion_interest, "should preserve booleans in person to keep"
    assert_equal "Gentle Lovers", person_to_keep.team_name, "should set team from person to merge"
    assert_equal 1, EventTeamMembership.count, "event team memberships"

    assert_equal 3, person_to_keep.versions.size, "versions in #{person_to_keep.versions}"
  end

  test "merge login" do
    person_to_keep = FactoryBot.create(:person)
    person_to_merge = FactoryBot.create(:person_with_login, login: "tonkin")

    Timecop.freeze(1.hour.from_now) do
      person_to_merge_old_password = person_to_merge.crypted_password

      assert_equal 1, person_to_merge.versions.size, "versions"
      assert_equal 1, person_to_keep.versions.size, "versions"
      person_to_keep.merge person_to_merge
      assert_equal 3, person_to_keep.versions.size, "Merge should keep initial versions from both, but: #{person_to_keep.versions}"

      person_to_keep.reload
      assert_equal "tonkin", person_to_keep.login, "Should merge login"
      assert_equal person_to_merge_old_password, person_to_keep.crypted_password, "Should merge password"
      changes = person_to_keep.versions.last.changeset
      assert_equal [nil, "tonkin"], changes["login"], "login change should be recorded"
    end
  end

  test "merge two logins" do
    person_to_keep = FactoryBot.create(:person, login: "molly", password: "secret")
    person_to_keep_old_password = person_to_keep.crypted_password

    person_to_merge = FactoryBot.create(:person, login: "tonkin", password: "secret")

    person_to_keep.reload
    person_to_merge.reload

    person_to_keep.merge person_to_merge

    person_to_keep.reload
    assert_equal "molly", person_to_keep.login, "Should preserve login"
    assert_equal person_to_keep_old_password, person_to_keep.crypted_password, "Should preserve password"
  end

  test "merge no alias dup names" do
    FactoryBot.create(:discipline, name: "Cyclocross")
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:number_issuer)

    person_to_keep = FactoryBot.create(:person, login: "molly", password: "secret")
    FactoryBot.create(:result, person: person_to_keep)
    FactoryBot.create(:result, person: person_to_keep)
    FactoryBot.create(:result, person: person_to_keep)
    person_to_keep.aliases.create!(name: "Mollie Cameron")

    person_to_merge = FactoryBot.create(:person, login: "tonkin", password: "secret")
    FactoryBot.create(:result, person: person_to_merge)
    FactoryBot.create(:result, person: person_to_merge)
    person_to_merge.aliases.create!(name: "Eric Tonkin")

    # Same name as merged
    Person.create(name: person_to_merge.name, road_number: "YYZ")

    assert Person.where(first_name: person_to_keep.first_name, last_name: person_to_keep.last_name).exists?, "#{person_to_keep.name} should be in DB"
    assert_equal(3, Result.where(person_id: person_to_keep.id).count, "Molly's results")
    assert_equal(1, Alias.where(aliasable_id: person_to_keep.id).count, "Mollys's aliases")

    assert Person.where(first_name: person_to_merge.first_name, last_name: person_to_merge.last_name).exists?, "#{person_to_merge.name} should be in DB"
    assert_equal(2, Result.where(person_id: person_to_merge.id).count, "Tonkin's results")
    assert_equal(1, Alias.where(aliasable_id: person_to_merge.id).count, "Tonkin's aliases")

    person_to_keep.merge(person_to_merge)

    assert Person.where(first_name: person_to_keep.first_name, last_name: person_to_keep.last_name).exists?, "#{person_to_keep.name} should be in DB"
    assert_equal(5, Result.where(person_id: person_to_keep.id).count, "Molly's results")
    aliases = Alias.where(aliasable_id: person_to_keep.id)
    erik_alias = aliases.detect { |a| a.name == "Erik Tonkin" }
    assert_nil(erik_alias, "Molly should not have Erik Tonkin alias because there is another Erik Tonkin")
    assert_equal(2, Alias.where(aliasable_id: person_to_keep.id).count, "Molly's aliases")

    assert Person.where(first_name: person_to_merge.first_name, last_name: person_to_merge.last_name).exists?, "#{person_to_merge.name} should still be in DB"
    assert_equal(0, Result.where(person_id: person_to_merge.id).count, "Tonkin's results")
    assert_equal(0, Alias.where(aliasable_id: person_to_merge.id).count, "Tonkin's aliases")
  end

  test "name" do
    person = Person.new(first_name: "Dario", last_name: "Frederick")
    assert_equal(person.name, "Dario Frederick", "name")
    person.name = ""
    assert_equal(person.name, "", "name")
  end

  test "set name" do
    person = Person.new(first_name: "R. Jim", last_name: "Smith")
    assert_equal "R. Jim", person.first_name, "first_name"
  end

  test "set single name" do
    person = Person.new(first_name: "Jim", last_name: "Smith")
    person.name = "Jim"
    assert_equal "Jim", person.name, "name"
  end

  test "name or login" do
    assert_nil Person.new.name_or_login
    assert_equal "dario@example.com", Person.new(email: "dario@example.com").name_or_login
    assert_equal "the_dario", Person.new(login: "the_dario").name_or_login
    assert_equal "Dario", Person.new(name: "Dario").name_or_login
  end

  test "member" do
    person = Person.new(first_name: "Dario", last_name: "Frederick")
    assert_equal(false, person.member?, "member")
    assert_nil(person.member_from, "Member from")
    assert_nil(person.member_to, "Member to")

    person.save!
    person.reload
    assert_equal(false, person.member?, "member")
    assert_nil(person.member_from, "Member on")
    assert_nil(person.member_to, "Member to")

    Timecop.freeze(Time.zone.local(2009, 6)) do
      person.member = true
      assert_equal(true, person.member?, "member")
      assert_equal_dates(Time.zone.local(2009, 6), person.member_from, "Member on")
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, "Member to")
      person.save!
      person.reload
      assert_equal(true, person.member?, "member")
      assert_equal_dates(Time.zone.local(2009, 6), person.member_from, "Member on")
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, "Member to")

      person.member = true
      assert_equal(true, person.member?, "member")
      assert_equal_dates(Time.zone.local(2009, 6), person.member_from, "Member on")
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, "Member to")
      person.save!
    end

    Timecop.freeze(Time.zone.local(2009, 12)) do
      person.reload
      assert_equal(true, person.member?, "member")
      assert_equal_dates(Time.zone.local(2009, 6), person.member_from, "Member on")
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, "Member to")
    end

    Timecop.freeze(Time.zone.local(2010)) do
      person.member_from = Time.zone.local(2010)
      person.member_to = Time.zone.local(2010, 12, 31)
      person.member = false
      assert_equal(false, person.member?, "member")
      assert_nil(person.member_from, "Member on")
      assert_nil(person.member_to, "Member to")
      person.save!
      person.reload
      assert_equal(false, person.member?, "member")
      assert_nil(person.member_from, "Member on")
      assert_nil(person.member_to, "Member to")
    end

    # From nil, to nil
    Timecop.freeze(Time.zone.local(2009)) do
      person.member_from = nil
      person.member_to = nil
      assert_equal(false, person.member?, "member?")
      person.member = true
      assert_equal(true, person.member?, "member")
      assert_equal_dates(Time.zone.local(2009), person.member_from, "Member from")
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, "Member to")

      person.member_from = nil
      person.member_to = nil
      assert_equal(false, person.member?, "member?")
      person.member = false
      person.member_from = nil
      person.member_to = nil
      assert_equal(false, person.member?, "member?")
    end

    # From, to in past
    Timecop.freeze(Time.zone.local(2009, 11)) do
      person.member_from = Time.zone.local(2001, 1, 1)
      person.member_to = Time.zone.local(2001, 12, 31)
      assert_equal(false, person.member?, "member?")
      assert_equal(false, person.member?(Time.zone.local(2000, 12, 31)), "member")
      assert_equal(true, person.member?(Time.zone.local(2001, 1, 1)), "member")
      assert_equal(true, person.member?(Time.zone.local(2001, 12, 31)), "member")
      assert_equal(false, person.member?(Time.zone.local(2002, 1, 1)), "member")
      person.member = true
      assert_equal(true, person.member?, "member")
      assert_equal_dates(Time.zone.local(2001, 1, 1), person.member_from, "Member from")
      assert_equal_dates(Time.zone.local(2009, 12, 31), person.member_to, "Member to")
    end

    Timecop.freeze(Time.zone.local(2009, 12, 16)) do
      person.member_from = Time.zone.local(2001, 1, 1)
      person.member_to = Time.zone.local(2001, 12, 31)
      assert_equal(false, person.member?, "member?")
      assert_equal(false, person.member?(Time.zone.local(2000, 12, 31)), "member")
      assert_equal(true, person.member?(Time.zone.local(2001, 1, 1)), "member")
      assert_equal(true, person.member?(Time.zone.local(2001, 12, 31)), "member")
      assert_equal(false, person.member?(Time.zone.local(2002, 1, 1)), "member")
      person.member = true
      assert_equal(true, person.member?, "member")
      assert_equal_dates(Time.zone.local(2001, 1, 1), person.member_from, "Member from")
      assert_equal_dates(Time.zone.local(2010, 12, 31), person.member_to, "Member to")
    end

    person.member_from = Time.zone.local(2001, 1, 1)
    person.member_to = Time.zone.local(2001, 12, 31)
    assert_equal(false, person.member?, "member?")
    person.member = false
    assert_equal_dates(Time.zone.local(2001, 1, 1), person.member_from, "Member from")
    person.member_to = Time.zone.local(2001, 12, 31)
    assert_equal(false, person.member?, "member?")

    # From in past, to in future
    Timecop.freeze(Time.zone.local(2009, 1)) do
      person.member_from = Time.zone.local(2001, 1, 1)
      person.member_to = Time.zone.local(3000, 12, 31)
      assert_equal(true, person.member?, "member?")
      person.member = true
      assert_equal(true, person.member?, "member")
      assert_equal_dates(Time.zone.local(2001, 1, 1), person.member_from, "Member from")
      assert_equal_dates(Time.zone.local(3000, 12, 31), person.member_to, "Member to")

      person.member = false
      assert_equal_dates(Time.zone.local(2001, 1, 1), person.member_from, "Member from")
      assert_equal_dates(Time.zone.local(2008, 12, 31), person.member_to, "Member to")
      assert_equal(false, person.member?, "member?")

      # From, to in future
      person.member_from = Time.zone.local(2500, 1, 1)
      person.member_to = Time.zone.local(3000, 12, 31)
      assert_equal(false, person.member?, "member?")
      person.member = true
      assert_equal(true, person.member?, "member")
      assert_equal_dates(Time.zone.local(2009), person.member_from, "Member from")
      assert_equal_dates("3000-12-31", person.member_to, "Member to")

      person.member = false
      assert_nil(person.member_from, "Member on")
      assert_nil(person.member_to, "Member to")
      assert_equal(false, person.member?, "member?")
    end
  end

  test "member in year" do
    person = Person.new(first_name: "Dario", last_name: "Frederick")
    assert_equal(false, person.member_in_year?, "member_in_year")
    assert_nil(person.member_from, "Member from")
    assert_nil(person.member_to, "Member to")

    person.member = true
    assert_equal(true, person.member_in_year?, "member_in_year")
    person.save!
    person.reload
    assert_equal(true, person.member_in_year?, "member_in_year")

    person.member = false
    assert_equal(false, person.member_in_year?, "member_in_year")
    person.save!
    person.reload
    assert_equal(false, person.member_in_year?, "member_in_year")

    # From, to in past
    person.member_from = Date.new(2001, 1, 1)
    person.member_to = Date.new(2001, 12, 31)
    assert_equal(false, person.member_in_year?, "member_in_year?")
    assert_equal(false, person.member_in_year?(Date.new(2000, 12, 31)), "member")
    assert_equal(true, person.member_in_year?(Date.new(2001, 1, 1)), "member")
    assert_equal(true, person.member_in_year?(Date.new(2001, 12, 31)), "member")
    assert_equal(false, person.member_in_year?(Date.new(2002, 1, 1)), "member")

    person.member_from = Date.new(2001, 4, 2)
    person.member_to = Date.new(2001, 6, 10)
    assert_equal(false, person.member_in_year?, "member_in_year?")
    assert_equal(false, person.member_in_year?(Date.new(2000, 12, 31)), "member")
    assert_equal(true, person.member_in_year?(Date.new(2001, 4, 1)), "member")
    assert_equal(true, person.member_in_year?(Date.new(2001, 4, 2)), "member")
    assert_equal(true, person.member_in_year?(Date.new(2001, 6, 10)), "member")
    assert_equal(true, person.member_in_year?(Date.new(2001, 6, 11)), "member")
    assert_equal(false, person.member_in_year?(Date.new(2002, 1, 1)), "member")
  end

  test "member to from nil to nil" do
    person = Person.new(first_name: "Dario", last_name: "Frederick")
    person.member_from = nil
    person.member_to = nil
    assert_equal(false, person.member?, "member?")
    assert_nil(person.member_from, "member_from")
    assert_nil(person.member_to, "member_to")
    person.save!
    assert_equal(false, person.member?, "member?")
    assert_nil(person.member_from, "member_from")
    assert_nil(person.member_to, "member_to")
  end

  test "member to from before to before" do
    person = Person.new(first_name: "Dario", last_name: "Frederick")
    person.member_from = Date.new(1970, 1, 1)
    person.member_to = Date.new(1970, 12, 31)
    person.member_to = Date.new(1971, 7, 31)

    assert_equal_dates(Date.new(1970, 1, 1), person.member_from, "Member from")
    assert_equal_dates("1971-07-31", person.member_to, "Member to")
    assert_equal(false, person.member?, "member?")
    person.save!
    assert_equal_dates(Date.new(1970, 1, 1), person.member_from, "Member from")
    assert_equal_dates("1971-07-31", person.member_to, "Member to")
    assert_equal(false, person.member?, "member?")
  end

  test "member to from before to after" do
    person = Person.new(first_name: "Dario", last_name: "Frederick")
    person.member_from = Date.new(1970, 1, 1)
    person.member_to = Date.new(1985, 12, 31)
    person.member_to = Date.new(1971, 7, 31)

    assert_equal_dates(Date.new(1970, 1, 1), person.member_from, "Member from")
    assert_equal_dates("1971-07-31", person.member_to, "Member to")
    assert_equal(false, person.member?, "member?")
    person.save!
    assert_equal_dates(Date.new(1970, 1, 1), person.member_from, "Member from")
    assert_equal_dates("1971-07-31", person.member_to, "Member to")
    assert_equal(false, person.member?, "member?")
  end

  test "member to from after to after" do
    person = Person.new(first_name: "Dario", last_name: "Frederick")
    person.member_from = Date.new(2006, 1, 1)
    person.member_to = Date.new(2006, 12, 31)
    person.member_to = Date.new(2000, 1, 31)

    assert_equal_dates(Date.new(2006, 1, 1), person.member_from, "Member from")
    assert_equal_dates("2000-01-31", person.member_to, "Member to")
    assert_equal(false, person.member?, "member?")
    person.save!
    assert_equal_dates(Date.new(2000, 1, 31), person.member_from, "Member from")
    assert_equal_dates("2000-01-31", person.member_to, "Member to")
    assert_equal(false, person.member?, "member?")
  end

  test "team name" do
    person = Person.new(first_name: "Dario", last_name: "Frederick")
    assert_equal(person.team_name, "", "name")

    person.team_name = "Vanilla"
    assert_equal("Vanilla", person.team_name, "name")

    person.team_name = "Pegasus"
    assert_equal("Pegasus", person.team_name, "name")

    person.team_name = ""
    assert_equal("", person.team_name, "name")
  end

  test "duplicate" do
    FactoryBot.create(:discipline, name: "Cyclocross")
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:number_issuer)

    Person.create(first_name: "Otis", last_name: "Guy")
    person = Person.new(first_name: "Otis", last_name: "Guy")
    assert(person.valid?, "Dupe person name with no number should be valid")

    person = Person.new(first_name: "Otis", last_name: "Guy", road_number: "180")
    assert(person.valid?, "Dupe person name valid even if person has no numbers")

    Person.create(first_name: "Otis", last_name: "Guy", ccx_number: "180")
    Person.create(first_name: "Otis", last_name: "Guy", ccx_number: "19")
  end

  test "master?" do
    person = Person.new
    assert(!person.master?, "Master?")

    person.date_of_birth = Date.new((RacingAssociation.current.masters_age - 1).years.ago.year, 1, 1)
    assert(!person.master?, "Master?")

    person.date_of_birth = Date.new(RacingAssociation.current.masters_age.years.ago.year, 12, 31)
    assert(person.master?, "Master?")

    person.date_of_birth = Date.new(17.years.ago.year, 1, 1)
    assert(!person.master?, "Master?")

    # Greater then 36 or so years in the past will give an ArgumentError on Windows
    person.date_of_birth = Date.new((RacingAssociation.current.masters_age + 1).years.ago.year, 12, 31)
    assert(person.master?, "Master?")
  end

  test "junior?" do
    person = Person.new
    assert(!person.junior?, "Junior?")

    person.date_of_birth = Date.new(19.years.ago.year, 1, 1)
    assert(!person.junior?, "Junior?")

    person.date_of_birth = Date.new(18.years.ago.year, 12, 31)
    assert(person.junior?, "Junior?")

    person.date_of_birth = Date.new(21.years.ago.year, 1, 1)
    assert(!person.junior?, "Junior?")

    person.date_of_birth = Date.new(12.years.ago.year, 12, 31)
    assert(person.junior?, "Junior?")
  end

  test "racing age" do
    person = Person.new
    assert_nil(person.racing_age)

    person.date_of_birth = 29.years.ago
    assert_equal(29, person.racing_age, "racing_age")

    person.date_of_birth = Date.new(29.years.ago.year, 1, 1)
    assert_equal(29, person.racing_age, "racing_age")

    person.date_of_birth = Date.new(29.years.ago.year, 12, 31)
    assert_equal(29, person.racing_age, "racing_age")

    person.date_of_birth = Date.new(30.years.ago.year, 12, 31)
    assert_equal(30, person.racing_age, "racing_age")

    person.date_of_birth = Date.new(28.years.ago.year, 1, 1)
    assert_equal(28, person.racing_age, "racing_age")
  end

  test "cyclocross racing age" do
    person = Person.new
    assert_nil(person.cyclocross_racing_age)

    person.date_of_birth = 29.years.ago
    assert_equal(30, person.cyclocross_racing_age, "cyclocross_racing_age")

    person.date_of_birth = Date.new(29.years.ago.year, 1, 1)
    assert_equal(30, person.cyclocross_racing_age, "cyclocross_racing_age")

    person.date_of_birth = Date.new(29.years.ago.year, 12, 31)
    assert_equal(30, person.cyclocross_racing_age, "cyclocross_racing_age")

    person.date_of_birth = Date.new(30.years.ago.year, 12, 31)
    assert_equal(31, person.cyclocross_racing_age, "cyclocross_racing_age")

    person.date_of_birth = Date.new(28.years.ago.year, 1, 1)
    assert_equal(29, person.cyclocross_racing_age, "cyclocross_racing_age")
  end

  test "bmx category" do
    person = FactoryBot.create(:person)
    assert_nil(person.bmx_category, "BMX category")
    person.bmx_category = "H100"
    assert_equal("H100", person.bmx_category, "BMX category")
  end

  test "blank numbers" do
    FactoryBot.create(:number_issuer)
    FactoryBot.create(:discipline, name: "Cyclocross")
    FactoryBot.create(:discipline, name: "Downhill")
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:discipline, name: "Time Trial")
    FactoryBot.create(:discipline, name: "Track")

    person = Person.new
    assert_nil(person.ccx_number, "cross number after new")
    assert_nil(person.dh_number, "dh number after new")
    assert_nil(person.road_number, "road number after new")
    assert_nil(person.track_number, "track number after new")
    assert_nil(person.xc_number, "xc number after new")

    person.save!
    person.reload
    assert_nil(person.ccx_number, "cross number after save")
    assert_nil(person.dh_number, "dh number after save")
    assert_nil(person.road_number, "road number after save")
    assert_nil(person.track_number, "track number after save")
    assert_nil(person.xc_number, "xc number after save")

    person = Person.update(
      person.id,
      ccx_number: "",
      dh_number: "",
      road_number: "",
      track_number: "",
      xc_number: ""
    )
    assert_nil(person.ccx_number, "cross number after update with empty string")
    assert_nil(person.dh_number, "dh number after update with empty string")
    assert_nil(person.road_number, "road number after update with empty string")
    assert_nil(person.track_number, "track number after update with empty string")
    assert_nil(person.xc_number, "xc number after update with empty string")

    person.reload
    assert_nil(person.ccx_number, "cross number after update with empty string")
    assert_nil(person.dh_number, "dh number after update with empty string")
    assert_nil(person.road_number, "road number after update with empty string")
    assert_nil(person.track_number, "track number after update with empty string")
    assert_nil(person.xc_number, "xc number after update with empty string")
  end

  test "numbers" do
    FactoryBot.create(:number_issuer)
    cyclocross = FactoryBot.create(:discipline, name: "Cyclocross")
    FactoryBot.create(:discipline_alias, discipline: cyclocross, alias: "cx")
    FactoryBot.create(:discipline_alias, discipline: cyclocross, alias: "ccx")
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:discipline, name: "Time Trial")

    person = FactoryBot.create(:person)
    tonkin = Person.create!(updater: person)
    tonkin.road_number = "102"
    road_number = tonkin.race_numbers.first
    assert_equal person, road_number.created_by, "created_by"
    tonkin.ccx_number = "U89"
    assert_equal("U89", tonkin.ccx_number)
    assert_equal("U89", tonkin.number(:ccx))
    assert_equal("U89", tonkin.number("ccx"))
    assert_equal("U89", tonkin.number("Cyclocross"))
    assert_equal("U89", tonkin.number(Discipline["Cyclocross"]))
    assert_equal "102", tonkin.number("Time Trial")
  end

  test "blank non-number discipline should not delete road number" do
    FactoryBot.create :number_issuer
    FactoryBot.create :discipline, name: "Road", numbers: true
    FactoryBot.create :discipline, name: "Track", numbers: false

    person = FactoryBot.create(:person, road_number: "1002")
    person = Person.find(person.id)
    assert_equal "1002", person.road_number

    person.track_number = nil
    person.save!

    person = Person.find(person.id)
    assert_equal "1002", person.road_number
  end

  test "date" do
    person = Person.new(date_of_birth: "0073-10-04")
    assert_equal_dates("1973-10-04", person.date_of_birth, "date_of_birth from 0073-10-04")

    person = Person.new(date_of_birth: "10/27/78")
    assert_equal_dates("1978-10-27", person.date_of_birth, "date_of_birth from 10/27/78")

    person = Person.new(date_of_birth: "78")
    assert_equal_dates("1978-01-01", person.date_of_birth, "date_of_birth from 78")
  end

  test "date of birth" do
    person = Person.new(date_of_birth: "1973-10-04")
    assert_equal_dates("1973-10-04", person.date_of_birth, "date_of_birth from 1973-10-04")
    assert_equal_dates("1973-10-04", person.birthdate, "birthdate from 173-10-04")

    person = Person.new(date_of_birth: "05/07/73")
    assert_equal_dates "1973-05-07", person.date_of_birth, "date_of_birth from 05/07/73"
  end

  test "find all by number" do
    FactoryBot.create(:number_issuer)
    FactoryBot.create(:discipline, name: "Road")
    person = FactoryBot.create(:person, road_number: "340")
    found_person = Person.find_all_by_number("340")
    assert_equal([person], found_person, "Should find Matson")
  end

  test "name_like" do
    assert_equal([], Person.name_like("foo123"), "foo123 should find no names")
    weaver = FactoryBot.create(:person, name: "Ryan Weaver")
    assert_equal([weaver], Person.name_like("eav"), "'eav' should find Weaver")

    weaver.last_name = "O'Weaver"
    weaver.save!
    assert_equal([weaver], Person.name_like("eav"), "'eav' should find O'Weaver")
    assert_equal([weaver], Person.name_like("O'Weaver"), "'O'Weaver' should find O'Weaver")

    weaver.last_name = "Weaver"
    weaver.save!
    Alias.create!(name: "O'Weaver", person: weaver)
    assert_equal([weaver], Person.name_like("O'Weaver"), "'O'Weaver' should find O'Weaver via alias")
  end

  test "where_name_or_number_like" do
    FactoryBot.create(:number_issuer)
    FactoryBot.create(:discipline, name: "Road")

    weaver = FactoryBot.create(:person, name: "Ryan Weaver", road_number: "666")
    weaver.aliases.create! name: "Brian Weaver"

    someone_else = FactoryBot.create(:person, name: "Scott Willson", road_number: "6")
    someone_else.aliases.create! name: "Scott Wilson"

    assert_equal [], Person.where_name_or_number_like("foo123"), "foo123 should find no names"
    assert_equal [weaver], Person.where_name_or_number_like("eav"), "'eav' should find Weaver"
    assert_equal [weaver], Person.where_name_or_number_like("Brian"), "'Brian' should find Weaver via alias"
    assert_equal [weaver], Person.where_name_or_number_like("666"), "'666' should find Weaver via road number"
  end

  test "find by name" do
    weaver = FactoryBot.create(:person, name: "Ryan Weaver")
    assert_equal weaver, Person.find_by(name: "Ryan Weaver"), "find_by_name"

    person = Person.create!(first_name: "Sam")
    assert_equal person, Person.find_by(name: "Sam"), "find_by_name first_name only"

    person = Person.create!(last_name: "Richardson")
    assert_equal person, Person.find_by(name: "Richardson"), "find_by_name last_name only"
  end

  test "hometown" do
    person = Person.new
    assert_equal("", person.hometown, "New Person hometown")

    person.city = "Newport"
    assert_equal("Newport", person.hometown, "Person hometown")

    person.city = nil
    person.state = RacingAssociation.current.state
    assert_equal("", person.hometown, "Person hometown")

    person.city = "Fossil"
    person.state = RacingAssociation.current.state
    assert_equal("Fossil", person.hometown, "Person hometown")

    person.city = nil
    person.state = "NY"
    assert_equal("NY", person.hometown, "Person hometown")

    person.city = "Petaluma"
    person.state = "CA"
    assert_equal("Petaluma, CA", person.hometown, "Person hometown")

    person = Person.new
    assert_nil(person.city, "New Person city")
    assert_nil(person.state, "New Person state")
    person.hometown = ""
    assert_nil(person.city, "New Person city")
    assert_nil(person.state, "New Person state")
    person.hometown = nil
    assert_nil(person.city, "New Person city")
    assert_nil(person.state, "New Person state")

    person.hometown = "Newport"
    assert_equal("Newport", person.city, "New Person city")
    assert_nil(person.state, "New Person state")

    person.hometown = "Newport, RI"
    assert_equal("Newport", person.city, "New Person city")
    assert_equal("RI", person.state, "New Person state")

    person.hometown = nil
    assert_nil(person.city, "New Person city")
    assert_nil(person.state, "New Person state")

    person.hometown = ""
    assert_nil(person.city, "New Person city")
    assert_nil(person.state, "New Person state")

    person.hometown = "Newport, RI"
    person.hometown = ""
    assert_nil(person.city, "New Person city")
    assert_nil(person.state, "New Person state")
  end

  test "create and override alias" do
    person = FactoryBot.create(:person, name: "Molly Cameron")
    person.aliases.create!(name: "Mollie Cameron")

    assert_not_nil(Person.find_by(name: "Molly Cameron"), "Molly Cameron should exist")
    assert_not_nil(Alias.find_by(name: "Mollie Cameron"), "Mollie Cameron alias should exist")
    assert_nil(Person.find_by(name: "Mollie Cameron"), "Mollie Cameron should not exist")

    dupe = Person.create!(name: "Mollie Cameron")
    assert(dupe.valid?, "Dupe Mollie Cameron should be valid")

    assert_not_nil(Person.find_by(name: "Molly Cameron"), "Molly Cameron should exist")
    assert_not_nil(Person.find_by(name: "Mollie Cameron"), "Ryan Weaver should exist")
    assert_nil(Alias.find_by(name: "Molly Cameron"), "Molly Cameron alias should not exist")
    assert_nil(Alias.find_by(name: "Mollie Cameron"), "Mollie Cameron alias should not exist")
  end

  test "update to alias" do
    person = FactoryBot.create(:person, name: "Molly Cameron")
    person.aliases.create!(name: "Mollie Cameron")

    # Reload to set old name correctly
    person = Person.find(person.id)

    person.name = "Mollie Cameron"
    person.save!
    assert(person.valid?, "Renamed Mollie Cameron should be valid")

    assert Person.exists?(name: "Mollie Cameron"), "Mollie Cameron should  exist"
    assert !Person.exists?(name: "Molly Cameron"), "Molly Cameron should not exist"
    assert !Alias.exists?(name: "Mollie Cameron"), "Mollie Cameron alias should exist"
    assert Alias.exists?(name: "Molly Cameron"), "Molly Cameron alias should exist"
  end

  test "sort" do
    r1 = Person.new(name: "Aarron Burr")
    r1.id = 1
    r2 = Person.new(name: "Aarron Car")
    r2.id = 2
    r3 = Person.new(name: "A Lincoln")
    r3.id = 3

    people = [r2, r1, r3]
    assert_equal([r1, r2, r3], people.sort, "sorted")
  end

  test "sort without ids" do
    r1 = Person.new(name: "Aarron Burr")
    r2 = Person.new(name: "Aarron Car")
    r3 = Person.new(name: "A Lincoln")

    people = [r2, r1, r3]
    assert_same_elements([r1, r2, r3], people.sort, "sorted")
  end

  test "add number" do
    FactoryBot.create :discipline, name: "Road"
    FactoryBot.create :number_issuer

    person = Person.create!
    event = FactoryBot.create(:event, name: "Bike Race")
    person.updater = event
    person.add_number "7890", nil
    person.reload
    assert_equal "7890", person.road_number, "Road number after add with nil discipline"
    assert_equal event, person.race_numbers.first.created_by, "Number created_by"
    assert_equal "Bike Race", person.race_numbers.first.created_by_name, "Number created_by"
    assert_equal "SingleDayEvent", person.race_numbers.first.created_by_type, "Number created_by"
  end

  test "add number from non number discipline" do
    FactoryBot.create :discipline, name: "Circuit", numbers: false
    FactoryBot.create :discipline, name: "Road"
    FactoryBot.create :number_issuer

    person = Person.create!
    circuit_race = Discipline[:circuit]
    person.add_number "7890", circuit_race
    assert_equal "7890", person.road_number, "Road number"
    assert_equal "7890", person.number(circuit_race), "Circuit race number"
  end

  test "other people with same name" do
    molly = FactoryBot.create(:person, name: "Molly Cameron")
    molly.aliases.create!(name: "Mollie Cameron")

    assert_equal([], molly.all_other_people_with_same_name, "No other people named 'Molly Cameron'")

    person = FactoryBot.create(:person, name: "Mollie Cameron")
    assert_equal([], molly.all_other_people_with_same_name, "No other people named 'Mollie Cameron'")

    Person.create!(name: "Mollie Cameron")
    assert_equal(1, person.all_other_people_with_same_name.size, "Other people named 'Mollie Cameron'")
  end

  test "force other_people_with_same_name for merge" do
    person = FactoryBot.create(:person, name: "Molly Cameron", other_people_with_same_name: true)
    person_2 = FactoryBot.create(:person, name: "Molly Cameron", other_people_with_same_name: true)

    assert !person_2.merge?(person), "merge? should honor other_people_with_same_name"
    assert !person.merge?(person_2), "merge? should honor other_people_with_same_name"

    assert person.merge?(person_2, force: true), "merge? should honor force argument"
  end

  test "dh number with no downhill discipline" do
    downhill = FactoryBot.create(:discipline, name: "Downhill")
    downhill.destroy
    Discipline.reset

    assert(!Discipline.exists?(name: "Downhill"), "Downhill should be deleted")
    person = FactoryBot.create(:person)
    assert_nil(person.dh_number, "DH number")
  end

  test "find all by name or alias" do
    tonkin = FactoryBot.create(:person, name: "Erik Tonkin")
    tonkin.aliases.create!(name: "Eric Tonkin")
    Person.create!(name: "Erik Tonkin")
    assert_equal(2, Person.find_all_by_name("Erik Tonkin").size, "Should have 2 Tonkins")
    assert_equal(2, Person.find_all_by_name_or_alias(first_name: "Erik", last_name: "Tonkin").size, "Should have 2 Tonkins")
    assert_raise(ArgumentError) { Person.find_all_by_name("Erik", "Tonkin") }
  end

  test "find all for export" do
    FactoryBot.create(:number_issuer)
    FactoryBot.create(:discipline, name: "Cyclocross")
    FactoryBot.create(:discipline, name: "Downhill")
    FactoryBot.create(:discipline, name: "Mountain Bike")
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:discipline, name: "Singlespeed")
    FactoryBot.create(:discipline, name: "Time Trial")
    FactoryBot.create(:discipline, name: "Track")

    FactoryBot.create(:person, name: "Molly Cameron")
    kona = FactoryBot.create(:team, name: "Kona")
    FactoryBot.create(
      :person,
      name: "Erik Tonkin",
      team: kona,
      track_category: "4"
    )
    FactoryBot.create(:person, name: "Mark Matson", team: kona)
    FactoryBot.create(
      :person,
      name: "Alice Pennington",
      date_of_birth: 30.years.ago,
      member_from: Date.new(1996),
      member_to: Time.zone.now.end_of_year.to_date,
      track_category: "5"
    )
    FactoryBot.create(:person, name: "Candi Murray")
    FactoryBot.create(:person)
    FactoryBot.create(:person, name: "Kevin Condron")

    people = Person.find_all_for_export
    assert_equal("Molly", people[0]["first_name"], "Row 0 first_name")
    assert_equal("Kona", people[2]["team_name"], "Row 2 team: #{people[2]}")
    assert_equal(30, people[4]["racing_age"], "Row 4 racing_age #{people[4]}")
    assert_equal_dates("1996-01-01", people[4]["member_from"], "Row 4 member_from")
    assert_equal_dates("#{Time.zone.now.year}-12-31", people[4]["member_to"], "Row 4 member_to")
    assert_equal("5", people[4]["track_category"], "Row 4 track_category")
  end

  test "find or create by name" do
    tonkin = FactoryBot.create(:person, name: "Erik Tonkin")
    person = Person.find_or_create_by(name: "Erik Tonkin")
    assert_equal tonkin, person, "Should find existing person"

    person = Person.find_or_create_by(name: "Sam Richardson")
    assert_equal "Sam Richardson", person.name, "New person name"
    assert_equal "Sam", person.first_name, "New person first_name"
    assert_equal "Richardson", person.last_name, "New person last_name"
    person_2 = Person.find_or_create_by(name: "Sam Richardson")
    assert_equal person, person_2, "Should find new person"

    person = Person.find_or_create_by(name: "Sam")
    assert_equal "Sam", person.name, "New person name"
    assert_equal "Sam", person.first_name, "New person first_name"
    assert_equal "", person.last_name, "New person last_name"
    person_2 = Person.find_or_create_by(name: "Sam")
    assert_equal person, person_2, "Should find new person"
  end

  test "create" do
    Person.create!(name: "Mr. Tuxedo", password: "blackcat", email: "tuxedo@example.com")
  end

  test "find by info" do
    promoter = FactoryBot.create(:promoter, name: "Brad Ross")
    assert_equal(promoter, Person.first_by_info("Brad ross"))
    assert_equal(promoter, Person.first_by_info("Brad ross", "brad@foo.com"))

    administrator = FactoryBot.create(:administrator)
    assert_equal(administrator, Person.first_by_info("Candi Murray"))
    assert_equal(administrator, Person.first_by_info("Candi Murray", "admin@example.com", "(503) 555-1212"))
    assert_equal(administrator, Person.first_by_info("", "admin@example.com", "(503) 555-1212"))
    assert_equal(administrator, Person.first_by_info("", "admin@example.com"))

    assert_nil(Person.first_by_info("", "mike_murray@obra.org", "(451) 324-8133"))
    assert_nil(Person.first_by_info("", "membership@obra.org"))

    promoter = Person.new(name: "", home_phone: "(212) 522-1872")
    promoter.save!
    assert_equal(promoter, Person.first_by_info("", "", "(212) 522-1872"))

    promoter = Person.new(name: "", email: "cjw@cjw.net")
    promoter.save!
    assert_equal(promoter, Person.first_by_info("", "cjw@cjw.net", ""))
  end

  test "save blank" do
    assert Person.new.valid?
  end

  test "save no name" do
    Person.create!(email: "nate@six-hobsons.net")
    assert(Person.new(email: "nate@six-hobsons.net").valid?, "Dupe email addresses allowed")
  end

  test "save no email" do
    assert Person.new(name: "Nate Hobson").valid?
  end

  test "administrator" do
    administrator = FactoryBot.create(:administrator)
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person)

    assert(administrator.administrator?, "administrator administrator?")
    assert(!promoter.administrator?, "promoter administrator?")
    assert(!member.administrator?, "administrator administrator?")
  end

  test "promoter" do
    administrator = FactoryBot.create(:administrator)
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person)

    assert !administrator.promoter?, "administrator promoter?"
    assert promoter.promoter?, "promoter promoter?"
    assert !member.promoter?, "person promoter?"
  end

  test "login with periods" do
    Person.create!(name: "Mr. Tuxedo", password: "blackcat", login: "tuxedo.cat@example.com")
  end

  test "long login" do
    person = Person.create!(
      name: "Mr. Tuxedo",
      password: "blackcatthebestkittyinblacktuxatonypa",
      login: "tuxedo.black.cat@subdomain123456789.example.com"
    )
    person.reload
    assert_equal "tuxedo.black.cat@subdomain123456789.example.com", person.login, "login"
    assert PersonSession.create!(
      login: "tuxedo.black.cat@subdomain123456789.example.com",
      password: "blackcatthebestkittyinblacktuxatonypa"
    )
  end

  test "ignore blank login fields" do
    Person.create!
    person = Person.create!(password: "", login: "")
    person.reload
    person.save!
    person.name = "New Guy"
    person.save!

    assert_nil person.login, "Login should be blank"
    another = Person.create!(login: "")
    another.reload
    assert_nil another.login, "Login should be blank"

    person.login = "samiam@example.com"
    person.password = "secret"
    person.save!

    another.login = "samiam@example.com"
    another.password = "secret"
    assert_equal false, another.save, "Should not allow dupe login"
    assert another.errors[:login], "Should have error on login"
  end

  test "authlogic should not set updated at on load" do
    person = Person.create!(name: "Joe Racer", updated_at: "2008-10-01")
    assert_equal_dates "2008-10-01", person.updated_at, "updated_at"
    person = Person.find(person.id)
    assert_equal_dates "2008-10-01", person.updated_at, "updated_at"
  end

  test "destroy with editors" do
    person = Person.create!
    alice = FactoryBot.create(:person)
    person.editors << alice
    assert alice.editable_people.any?, "should be editor"
    person.destroy!
    assert !Person.exists?(person.id)
    assert alice.editable_people.reload.empty?, "should remove editors"
  end

  test "multiple names" do
    person = FactoryBot.create(:person, name: "Ryan Weaver")

    person.names.create!(first_name: "R", last_name: "Weavedog", name: "R Weavedog", year: 2001)
    person.names.create!(first_name: "Mister", last_name: "Weavedog", name: "Mister Weavedog", year: 2002)
    person.names.create!(first_name: "Ryan", last_name: "Farris", name: "Ryan Farris", year: 2003)

    assert_equal(3, person.names.size, "Historical names. #{person.names.map(&:name).join(', ')}")

    assert_equal("R Weavedog", person.name(2000), "Historical name 2000")
    assert_equal("R", person.first_name(2000), "Historical first_name 2000")
    assert_equal("Weavedog", person.last_name(2000), "Historical last_name 2000")

    assert_equal("R Weavedog", person.name(2001), "Historical name 2001")
    assert_equal("R", person.first_name(2001), "Historical first_name 2001")
    assert_equal("Weavedog", person.last_name(2001), "Historical last_name 2001")

    assert_equal("Mister Weavedog", person.name(2002), "Historical name 2002")
    assert_equal("Mister", person.first_name(2002), "Historical first_name 2002")
    assert_equal("Weavedog", person.last_name(2002), "Historical last_name 2002")

    assert_equal("Ryan Farris", person.name(2003), "Historical name 2003")
    assert_equal("Ryan Weaver", person.name(2004), "Historical name 2004")
    assert_equal("Ryan Weaver", person.name(Time.zone.today.year - 1), "Historical name last year")
    assert_equal("Ryan Weaver", person.name(Time.zone.today.year), "Name this year")
    assert_equal("Ryan Weaver", person.name(Time.zone.today.year + 1), "Name next year")
  end

  test "create new name if there are results from previous year" do
    senior_men = FactoryBot.create(:category)
    old_result = nil
    person = nil

    Timecop.freeze(1.year.ago) do
      person = FactoryBot.create(:person, name: "Ryan Weaver")
      person = Person.find(person.id)
      event = SingleDayEvent.create!
      old_result = event.races.create!(category: senior_men).results.create!(person: person)
    end

    assert_equal("Ryan Weaver", old_result.name, "Name on old result")
    assert_equal("Ryan", old_result.first_name, "first_name on old result")
    assert_equal("Weaver", old_result.last_name, "last_name on old result")

    event = SingleDayEvent.create!
    result = event.races.create!(category: senior_men).results.create!(person: person)
    assert_equal("Ryan Weaver", old_result.name, "Name on old result")
    assert_equal("Ryan", old_result.first_name, "first_name on old result")
    assert_equal("Weaver", old_result.last_name, "last_name on old result")

    person.reload
    person.name = "Rob Farris"
    person.save!

    assert_equal(1, person.names.reload.size, "names")

    assert_equal("Ryan Weaver", old_result.reload.name, "name should stay the same on old result")
    assert_equal("Ryan", old_result.first_name, "first_name on old result")
    assert_equal("Weaver", old_result.last_name, "last_name on old result")

    assert_equal("Rob Farris", result.reload.name, "name should change on this year's result")
    assert_equal("Rob", result.first_name, "first_name on result")
    assert_equal("Farris", result.last_name, "last_name on result")
  end

  test "renewed" do
    person = Person.create!
    assert !person.renewed?, "New person"

    Timecop.freeze(Date.new(2009, 11, 30)) do
      person = Person.create!(member_from: Date.new(2009, 1, 1), member_to: Date.new(2009, 12, 31))
      assert person.renewed?, "Before Dec 1"
    end

    person = Person.create!(member_from: Date.new(2009, 1, 1), member_to: Date.new(2009, 12, 31))
    Timecop.freeze(Time.zone.local(2009, 12, 1)) do
      assert !person.renewed?, "On Dec 1"
    end

    Timecop.freeze(Date.new(2010, 1, 1)) do
      assert !person.renewed?, "Next year"
    end
  end

  test "can edit" do
    p1 = Person.create!
    p2 = Person.create!
    admin = FactoryBot.create(:administrator)

    assert !p1.can_edit?(p2)
    assert !p1.can_edit?(admin)
    assert p1.can_edit?(p1)
    assert !p2.can_edit?(p1)
    assert !p2.can_edit?(admin)
    assert p2.can_edit?(p2)
    assert admin.can_edit?(p1)
    assert admin.can_edit?(p2)
    assert admin.can_edit?(admin)

    p1.editors << p2
    assert !p1.can_edit?(p2)
    assert !p1.can_edit?(admin)
    assert p1.can_edit?(p1)
    assert p2.can_edit?(p1)
    assert !p2.can_edit?(admin)
    assert p2.can_edit?(p2)
    assert admin.can_edit?(p1)
    assert admin.can_edit?(p2)
    assert admin.can_edit?(admin)

    p2.editors << p1
    assert p1.can_edit?(p2)
    assert !p1.can_edit?(admin)
    assert p1.can_edit?(p1)
    assert p2.can_edit?(p1)
    assert !p2.can_edit?(admin)
    assert p2.can_edit?(p2)
    assert admin.can_edit?(p1)
    assert admin.can_edit?(p2)
    assert admin.can_edit?(admin)

    admin.editors << p1
    assert p1.can_edit?(p2)
    assert p1.can_edit?(admin)
    assert p1.can_edit?(p1)
    assert p2.can_edit?(p1)
    assert !p2.can_edit?(admin)
    assert p2.can_edit?(p2)
    assert admin.can_edit?(p1)
    assert admin.can_edit?(p2)
    assert admin.can_edit?(admin)
  end

  test "event editor" do
    event = FactoryBot.create(:event)
    person = FactoryBot.create(:person)

    assert event.editors.empty?, "Event should have no editors"
    assert_not_nil event.promoter, "Event should have promoter"
    assert_equal [event], event.promoter.events, "Promoter should have event in events"
    assert person.events, "Person should not have event in events"
    assert event.promoter.editable_events.empty?, "Promoter should have no editable_events"
    assert person.editable_events.empty?, "Person should have no editable_events"

    event.editors << person
    assert_equal [person], event.editors, "Event should have editor"
    assert_equal [event], event.promoter.events, "Promoter should have event in events"
    assert_equal [], person.events, "Person should not have event in events"
    assert event.promoter.editable_events.empty?, "Promoter should have no editable_events"
    assert_equal [event], person.editable_events.reload, "Person should have editable_events"
    assert person.promoter?, "Editors should be considered promoters"
  end

  test "blank licenses" do
    Person.create!(license: "")
    Person.create!(license: "")
  end

  def assert_renew(now, member_from, member_to, expected_member_from, expected_member_to)
    now = now.to_date
    person = Person.new
    person.renew(now)
    assert_equal true, person.member?(now), "member? for #{now.to_formatted_s(:db)}. Member: #{member_from&.to_formatted_s(:db)}- #{member_to&.to_formatted_s(:db)}"
    assert_equal_dates expected_member_from, person.member_from, "member_from for #{now.to_formatted_s(:db)}. Member: #{member_from&.to_formatted_s(:db)}- #{member_to&.to_formatted_s(:db)}"
    assert_equal_dates expected_member_to, person.member_to, "member_to for #{now.to_formatted_s(:db)}. Member: #{member_from&.to_formatted_s(:db)}- #{member_to&.to_formatted_s(:db)}"
  end
end
