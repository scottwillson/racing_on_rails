require "test_helper"

module Competitions
  # :stopdoc:
  class ResultsControllerTest < ActionController::TestCase
    tests ResultsController

    def setup
      super

      association_category = FactoryGirl.create(:category, name: "CBRA")
      @senior_men          = FactoryGirl.create(:category, name: "Senior Men", parent: association_category)
      @senior_women        = FactoryGirl.create(:category, name: "Senior Women", parent: association_category)

      discipline = FactoryGirl.create(:discipline, name: "Road")
      discipline.bar_categories << @senior_men
      discipline.bar_categories << @senior_women

      discipline = FactoryGirl.create(:discipline, name: "Time Trial")
      discipline.bar_categories << @senior_men
      discipline.bar_categories << @senior_women

      discipline = FactoryGirl.create(:discipline, name: "Overall")
      discipline.bar_categories << @senior_men
      discipline.bar_categories << @senior_women
    end

    test "person" do
      weaver = FactoryGirl.create(:person)
      weaver_banana_belt = FactoryGirl.create(:result, person: weaver, category: @senior_men)
      competition = RiderRankings.create!
      competition_result = competition.races.create!(category: @senior_men).results.create!
      Score.create!(competition_result: competition_result, source_result: weaver_banana_belt, points: 1)

      get :person, person_id: weaver.to_param
      assert_response(:success)
      assert_template("results/person")
      assert_not_nil(assigns["person"], "Should assign person")
      assert_equal(assigns["person"], weaver, "Weaver!")
    end

    test "competition" do
      person = FactoryGirl.create(:person)
      FactoryGirl.create(:event, date: Date.new(2004)).races.create!(category: @senior_women).results.create!(place: "1", person: person)

      Competitions::Bar.calculate!(2004)
      bar = Bar.year(2004).where(discipline: "Road").first

      get :person_event, event_id: bar.to_param, person_id: person.to_param
      assert_response :success
      assert_template "results/person_event"
      assert_not_nil assigns["results"], "Should assign results"
      assert_equal 1, assigns["results"].size, "Should assign results"
      assert_equal assigns["person"], person, "Should assign person"
      assert_equal assigns["event"], bar, "Should assign event"
    end

    # A Competition calculated from another Competition
    test "overall bar" do
      FactoryGirl.create(:event, date: Date.new(2004)).races.create!(category: @senior_women).results.create!(place: "1", person: FactoryGirl.create(:person))
      event = FactoryGirl.create(:event, date: Date.new(2004))
      FactoryGirl.create(:result, event: event)

      Competitions::Bar.calculate!(2004)
      bar = Bar.year(2004).where(discipline: "Road").first
      result = bar.races.detect {|r| r.name == 'Senior Women'}.results.first
      assert_not_nil(result, 'result')
      assert_not_nil(result.person, 'result.person')

      Competitions::OverallBar.calculate!(2004)
      overall_bar = Competitions::OverallBar.find_for_year(2004)
      result = overall_bar.races.detect {|r| r.name == 'Senior Women'}.results.first
      assert_not_nil(result, 'result')

      get(:person_event, event_id: overall_bar.to_param, person_id: result.person.to_param)
      assert_response(:success)
      assert_template("results/person_event")
      assert_not_nil(assigns["results"], "Should assign results")
      assert_equal(1, assigns["results"].size, "Should assign results")
      assert_equal(assigns["person"], result.person, "Should assign person")
      assert_equal(assigns["event"], overall_bar, "Should assign event")
    end

    test "redirect to ironman" do
      event = Ironman.create!
      get :event, event_id: event.to_param
      assert_redirected_to ironman_path(year: event.year)
    end

    test "cross crusade team competition" do
      event = CrossCrusadeTeamCompetition.create!(parent: Series.create!)
      get :event, event_id: event.to_param
      assert_template "results/event"
    end

    test "event bar" do
      bar = Bar.create!
      get :event, event_id: bar.to_param
      assert_redirected_to(controller: "competitions/bar", action: "show", year: bar.date.year, discipline: bar.discipline)
    end

    test "event rider rankings" do
      rider_rankings = RiderRankings.create!
      get(:event, event_id: rider_rankings.to_param)
      assert_redirected_to(rider_rankings_path(rider_rankings.date.year))
    end

    test "event overall bar" do
      bar = OverallBar.create!
      get(:event, event_id: bar.to_param)
      assert_redirected_to(controller: "competitions/bar", action: "show", year: bar.date.year)
    end

    test "empty competition" do
      bar = Competitions::Bar.create!
      person = Person.create!(name: 'JP Morgen')

      get(:person_event, event_id: bar.to_param, person_id: person.to_param)
      assert_response(:success)
      assert_template("results/person_event")
      assert_equal(assigns["results"], [], "Should assign results")
      assert_equal(assigns["person"], person, "Should assign person")
      assert_equal(assigns["event"], bar, "Should assign event")
    end

    test "competition team" do
      FactoryGirl.create(:discipline, name: "Team")
      team = Team.create!(name: "dfl", member: true)
      person = FactoryGirl.create(:person)
      FactoryGirl.create(:event, date: Date.new(2004, 2)).races.create!(category: @senior_women).results.create!(place: "1", person: person, team: team)
      Bar.calculate!(2004)
      TeamBar.calculate!(2004)
      bar = TeamBar.first
      result = bar.races.first.results.first
      assert_not_nil(result, 'result')
      assert_not_nil result.team, "result.team"

      get :team_event, event_id: bar.to_param, team_id: result.team.to_param

      assert_response(:success)
      assert_template("results/team_event")
      assert_equal([result], assigns["results"], "Should assign result")
    end

    test "person with overall results" do
      person = FactoryGirl.create(:person)
      event = CrossCrusadeOverall.create!(parent: Series.create!)
      @senior_men = FactoryGirl.create(:category)
      event.races.create!(category: @senior_men).results.create!(place: "1")
      get :person, person_id: person.to_param
      assert_response :success
    end

    test "person overall results" do
      person = FactoryGirl.create(:person)
      event = CrossCrusadeOverall.create!(parent: Series.create!)
      @senior_men = FactoryGirl.create(:category)
      event.races.create!(category: @senior_men).results.create!(place: "1")
      get(:person_event, event_id: event.to_param, person_id: person.to_param)
      assert_response :success
    end

    test "missing person event result" do
      Bar.create!
      event = Bar.find_for_year
      get(:person_event, event_id: event.to_param, person_id: Person.create!.to_param)
      assert_response :success
    end
  end
end
