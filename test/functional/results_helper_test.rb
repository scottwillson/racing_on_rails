require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ResultsHelperTest < ActionView::TestCase
  setup do
    self.stubs(:mobile_request? => false)
  end

  def test_results_table
    race = Race.new(:results => [ Result.new(:place => "1")])
    table = Nokogiri::HTML(results_table(race))
    assert table.css("table.results").present?
  end

  def test_results_table_one_ttt
    race = Race.new(:results => [ 
      Result.new(:place => "1"),
      Result.new(:place => "1"),
      Result.new(:place => "1")
    ])
    table = Nokogiri::HTML(results_table(race))
    assert table.css("table.results").present?
    assert table.css("td.place").present?, "Should have place column in #{table}"
  end

  def test_participant_event_results_table_person
    table = Nokogiri::HTML(participant_event_results_table(Person.new, [ Result.new(:place => "1") ]))
    assert table.css("table.results").present?
  end

  def test_participant_event_results_table_team
    table = Nokogiri::HTML(participant_event_results_table(Team.new, [ Result.new(:place => "1") ]))
    assert table.css("table.results").present?
  end

  def test_edit_results_table
    race = FactoryGirl.create(:result).race
    table = Nokogiri::HTML(edit_results_table(race))
    assert table.css("table.results").present?
  end

  def test_scores_table
    table = Nokogiri::HTML(scores_table(Result.new(:place => "1")))
    assert table.css("table.results.scores").present?
  end

  def test_results_table_for_mobile
    self.stubs(:mobile_request? => true)

    race = Race.new(:results => [ Result.new(:place => "1", :name => "Molly Cameron", :team_name => "Veloshop", :time => 1000, :laps => 4)])

    table = Nokogiri::HTML(results_table(race))
    assert table.css("table th.place").present?
    assert table.css("table th.name").present?
    assert table.css("table th.team_name").empty?, "only show mobile columns"
    assert table.css("table th.points").empty?, "only show mobile columns"
    assert table.css("table th.laps").empty?, "only show mobile columns"
  end
end
