require_relative "../test_case"
require_relative "../../../lib/renderers/team_name_renderer"
require "nokogiri"

# :stopdoc:
module Renderers
  class TeamNameRendererTest < Ruby::TestCase
    def test_render_no_team
      column = mock("column", key: :team_name)
      row = mock("row", :[] => nil, source: mock("result", team_id: nil))
      assert_nil TeamNameRenderer.render(column, row), "Result with no text, no team"
    end

    def test_render_team
      column = stub("column", key: :team_name)
      row = stub("row", :[] => "Gentle Lovers", metadata: {}, source: stub("result", team_id: 18, :team_competition_result? => false, year: 2010))
      TeamNameRenderer.stubs(racing_association: mock("racing_association", :unregistered_teams_in_results? => true))

      html = TeamNameRenderer.render(column, row)
      link = Nokogiri::HTML.fragment(html).search('a').first
      assert_equal "/teams/18/2010", link['href'], "href"
      assert_equal "Gentle Lovers", link.text, "text"
    end

    def test_mobile
      column = stub("column", key: :team_name)
      row = stub("row", :[] => "Gentle Lovers", metadata: { mobile_request: true }, source: stub("result", team_id: 18, :team_competition_result? => false, year: 2010))
      TeamNameRenderer.stubs(racing_association: mock("racing_association", :unregistered_teams_in_results? => true))

      html = TeamNameRenderer.render(column, row)
      link = Nokogiri::HTML.fragment(html).search('a').first
      assert_equal "/m/teams/18/2010", link['href'], "href"
      assert_equal "Gentle Lovers", link.text, "text"
    end

    def test_competition_result
      column = stub("column", key: :team_name)
      row = stub("row",
                   :[] => "Gentle Lovers",
                   metadata: {},
                   source: stub("result", team_id: 18, event_id: 3, race_id: 200, :team_competition_result? => true, year: 2010))
      TeamNameRenderer.stubs(racing_association: mock("racing_association", :unregistered_teams_in_results? => true))

      html = TeamNameRenderer.render(column, row)
      link = Nokogiri::HTML.fragment(html).search('a').first
      assert_equal "/events/3/teams/18/results#200", link['href'], "href"
      assert_equal "Gentle Lovers", link.text, "text"
    end
  end
end
