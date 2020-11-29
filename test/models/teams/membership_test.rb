# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

module Teams
  # :stopdoc:
  class TeamTest < ActiveSupport::TestCase
    test "member?" do
      team = Team.new(name: "Team Spine")
      assert_equal(false, team.member?, "member?")
      assert_nil(team.member_from, "member_from")
      assert_nil(team.member_to, "member_to")
      team.save!
      team.reload
      assert_equal(false, team.member?, "member?")
      assert_nil(team.member_from, "member_from")
      assert_nil(team.member_to, "member_to")

      Timecop.freeze(2000, 6) do
        team = Team.new(name: "California Road Club")
        assert_equal(false, team.member?, "member?")
        team.member = true
        assert_equal(true, team.member?, "member?")
        assert_equal(2000, team.member_from, "member_from")
        assert_equal(2000, team.member_to, "member_to")
        team.save!
        team.reload
        assert_equal(true, team.member?, "member?")
        assert_equal(2000, team.member_from, "member_from")
        assert_equal(2000, team.member_to, "member_to")

        team.member = true
        team.save!
        team.reload
        assert_equal(true, team.member?, "member?")

        team.member = false
        team.save!
        team.reload
        assert_equal(false, team.member?, "member?")
        assert_nil(team.member_from, "member_from")
        assert_nil(team.member_to, "member_to")

        team.member_from = 1990
        team.member_to = 1999
        assert_equal(false, team.member?, "member?")
        team.save!
        team.reload
        assert_equal(false, team.member?, "member?")
        assert_equal(1990, team.member_from, "member_from")
        assert_equal(1999, team.member_to, "member_to")

        team.member = false
        team.save!
        team.reload
        assert_equal(false, team.member?, "member?")
        assert_equal(1990, team.member_from, "member_from")
        assert_equal(1999, team.member_to, "member_to")
      end

      Timecop.freeze(2001, 6) do
        assert_equal(false, team.member?, "member?")
      end
    end

    test "membership honors effective year" do
      Timecop.freeze(2020, 11, 30) do
        assert_equal(false, Team.new.member?, "member?")
        assert_equal(false, Team.new(member_from: 2020).member?, "member?")
        assert_equal(false, Team.new(member_from: 2019).member?, "member?")
        assert_equal(false, Team.new(member_from: 2018, member_to: 2018).member?, "member?")
        assert_equal(false, Team.new(member_from: 2018, member_to: 2019).member?, "member?")
        assert_equal(false, Team.new(member_from: 2019, member_to: 2019).member?, "member?")
        assert_equal(true, Team.new(member_from: 2018, member_to: 2020).member?, "member?")
        assert_equal(true, Team.new(member_from: 2019, member_to: 2020).member?, "member?")
        assert_equal(true, Team.new(member_from: 2020, member_to: 2020).member?, "member?")
        assert_equal(true, Team.new(member_from: 2020, member_to: 2021).member?, "member?")
        assert_equal(false, Team.new(member_from: 2021, member_to: 2021).member?, "member?")
      end
    end
  end
end
