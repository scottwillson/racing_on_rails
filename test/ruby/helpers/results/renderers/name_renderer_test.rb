require_relative "../test_case"
require_relative "../../../lib/renderers/name_renderer"
require "nokogiri"

module Results
  module Renderers
    # :stopdoc:
    class NameRendererTest < Ruby::TestCase
      def test_render_no_person
        column = mock("column", key: :name)
        row = mock("row", :[] => nil, source: mock("result", person_id: nil))
        assert_nil NameRenderer.render(column, row), "Result with no text, no person"
      end

      def test_render_name
        column = stub("column", key: :name)
        row = stub(
                "row",
                :[] => "Candi Murray",
                metadata: {},
                source: stub("result", person_id: 18, :competition_result? => false, year: 2010, :preliminary? => false)
        )

        html = NameRenderer.render(column, row)
        link = Nokogiri::HTML.fragment(html).search('a').first
        assert_equal "/people/18/2010", link['href'], "href"
        assert_equal "Candi Murray", link.text, "text"
      end

      def test_mobile
        column = stub("column", key: :name)
        row = stub(
                "row",
                :[] => "Candi Murray",
                metadata: { mobile_request: true },
                source: stub("result", person_id: 18, :competition_result? => false, year: 2010, :preliminary? => false)
        )

        html = NameRenderer.render(column, row)
        link = Nokogiri::HTML.fragment(html).search('a').first
        assert_equal "/m/people/18/2010", link['href'], "href"
        assert_equal "Candi Murray", link.text, "text"
      end

      def test_competition_result
        column = stub("column", key: :name)
        row = stub("row",
                     :[] => "Mike Murray",
                     metadata: {},
                     source: stub(
                       "result",
                       person_id: 18, event_id: 3, race_id: 200, :competition_result? => true, year: 2010, :preliminary? => false)
                     )
        # TeamNameRenderer.stubs(racing_association: mock("racing_association", :unregistered_teams_in_results? => true))

        html = NameRenderer.render(column, row)
        link = Nokogiri::HTML.fragment(html).search('a').first
        assert_equal "/events/3/people/18/results#200", link['href'], "href"
        assert_equal "Mike Murray", link.text, "text"
      end
    end
  end
end
