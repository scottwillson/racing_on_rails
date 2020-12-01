# frozen_string_literal: true

require File.expand_path("../../../test_helper", __dir__)

# :stopdoc:
module Admin
  module People
    class ExportTest < ActionController::TestCase
      tests Admin::PeopleController

      def setup
        super
        create_administrator_session
        use_ssl

        FactoryBot.create(:discipline, name: "Cyclocross")
        FactoryBot.create(:discipline, name: "Downhill")
        FactoryBot.create(:discipline, name: "Mountain Bike")
        FactoryBot.create(:discipline, name: "Road")
        FactoryBot.create(:discipline, name: "Singlespeed")
        FactoryBot.create(:discipline, name: "Track")
        FactoryBot.create(:number_issuer)
      end

      test "export to excel" do
        Timecop.freeze(Time.zone.local(2012, 11, 1)) do
          Person.destroy_all

          FactoryBot.create(:person, name: "", email: "sixhobsons@comcast.net", home_phone: "(503) 223-3343", member: false, member_from: nil, member_to: nil)
          FactoryBot.create(:person, name: "Molly Cameron", team_name: "Vanilla", member_from: Time.zone.local(1999).beginning_of_year, member_to: Time.zone.now.end_of_year.to_date, gender: "F", road_number: "202")
          FactoryBot.create(:person, name: "Kevin Con'Condron", license: "576", team_name: "Gentle Lovers", member_from: Time.zone.local(2000), member_to: Time.zone.local(2011).end_of_year.to_date, email: "kc@example.com")
          FactoryBot.create(:person, name: "Bob Jones", member_from: Time.zone.local(2009), member_to: Time.zone.local(2009).end_of_year.to_date, email: "member@example.com")
          FactoryBot.create(:person, name: "Mark Matson", license: "578", member_from: Time.zone.local(1999), member_to: Time.zone.now.end_of_year.to_date, team_name: "Kona", email: "mcfatson@gentlelovers.com", gender: "M", road_number: "340")
          administrator = FactoryBot.create(:administrator, member_from: nil, member_to: nil)
          PersonSession.create(administrator)
          FactoryBot.create(:person, name: "Alice Pennington", team_name: "Gentle Lovers", member_from: Time.zone.local(1999), member_to: Time.zone.now.end_of_year.to_date, road_number: "230", gender: "F")
          FactoryBot.create(:person, name: "Non Results", member_from: nil, member_to: nil)
          FactoryBot.create(:person, name: "Brad Ross", member_from: nil, member_to: nil, notes: "Hey,\n I’ve got some \"bad\" characters")

          tonkin = FactoryBot.create(:person, singlespeed_number: "409", track_number: "765", name: "Erik Tonkin", member_from: Time.zone.local(1999), member_to: Time.zone.now.end_of_year.to_date, date_of_birth: Time.zone.local(1982, 9, 10), street: "127 SE Lambert", city: "Portland", state: "OR", zip: "19990", home_phone: "415 221-3773", gender: "M", road_category: "1", track_category: "5", road_number: "102", license: "7123811", team_name: "Kona")
          tonkin.race_numbers.create!(discipline: Discipline[:singlespeed], value: "410")

          weaver = FactoryBot.create(:person, name: "Ryan Weaver", email: "hotwheels@yahoo.com", gender: "M", road_number: "341", xc_number: "437", team_name: "Gentle Lovers")
          weaver.race_numbers.create!(discipline: Discipline[:road], value: "888")
          weaver.race_numbers.create!(discipline: Discipline[:road], value: "999")

          get :index, params: { format: "xls", include: "all" }

          assert_response :success
          assert_equal("filename=\"people_2012_11_1.xls\"", @response.headers["Content-Disposition"], "Should set disposition")
          assert_equal("application/vnd.ms-excel; charset=utf-8", @response.headers["Content-Type"], "Should set content to Excel")
          # FIXME: use send_data
          assert_equal(11, assigns["people"].to_a.size, "People export size")

          expected_body = [
            "license	first_name	last_name	team_name	member_from	member_to	fabric_road_numbers	print_card	card_printed_at	membership_card	date_of_birth	occupation	street	city	state	zip	wants_mail	email	wants_email	home_phone	work_phone	cell_fax	gender	road_category	track_category	ccx_category	mtb_category	dh_category	ccx_number	dh_number	road_number	singlespeed_number	track_number	xc_number	notes	volunteer_interest	official_interest	race_promotion_interest	team_interest	velodrome_committee_interest	created_at	updated_at\n",
            "						1	0		0							0	sixhobsons@comcast.net	0	(503) 223-3343																0	0	0	0	0	11/1/2012	11/1/2012\n",
            "	Molly	Cameron	Vanilla	1/1/1999	12/31/2012	1	0		0							0		0				F								202					0	0	0	0	0	11/1/2012	11/1/2012\n",
            "576	Kevin	Con'Condron	Gentle Lovers	1/1/2000	12/31/2011	1	0		0							0	kc@example.com	0																	0	0	0	0	0	11/1/2012	11/1/2012\n",
            "	Bob	Jones		1/1/2009	12/31/2009	1	0		0							0	member@example.com	0																	0	0	0	0	0	11/1/2012	11/1/2012\n",
            "578	Mark	Matson	Kona	1/1/1999	12/31/2012	1	0		0							0	mcfatson@gentlelovers.com	0				M								340					0	0	0	0	0	11/1/2012	11/1/2012\n",
            "	Candi	Murray				1	0		0							0	admin@example.com	0	(503) 555-1212																0	0	0	0	0	11/1/2012	11/1/2012\n",
            "	Alice	Pennington	Gentle Lovers	1/1/1999	12/31/2012	1	0		0							0		0				F								230					0	0	0	0	0	11/1/2012	11/1/2012\n",
            "	Non	Results				1	0		0							0		0																	0	0	0	0	0	11/1/2012	11/1/2012\n",
            "	Brad	Ross				1	0		0							0		0																\"Hey,  I’ve got some \\\"bad\\\" characters\"	0	0	0	0	0	11/1/2012	11/1/2012\n",
            "7123811	Erik	Tonkin	Kona	1/1/1999	12/31/2012	1	0		0	9/10/1982		127 SE Lambert	Portland	OR	19990	0		0	415 221-3773			M	1	5						102	409				0	0	0	0	0	11/1/2012	11/1/2012\n",
            "	Ryan	Weaver	Gentle Lovers	1/1/2000	12/31/2012	1	0		0							0	hotwheels@yahoo.com	0				M								341			437		0	0	0	0	0	11/1/2012	11/1/2012\n"
          ].reverse

          unless File.exist?("local/app/views/admin/people/index.xls.erb")
            @response.body.lines.each do |line|
              assert_equal expected_body.pop, line
            end
          end
        end
      end

      test "export to excel with date" do
        get :index, format: "xls", params: { include: "all", date: "2008-12-31" }

        assert_response :success
        assert_equal("filename=\"people_2008_12_31.xls\"", @response.headers["Content-Disposition"], "Should set disposition")
        assert_equal("application/vnd.ms-excel; charset=utf-8", @response.headers["Content-Type"], "Should set content to Excel")
        # FIXME: use send_data
        # assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
        assert_equal(1, assigns["people"].count, "People export size")
      end

      test "export members only to excel" do
        get :index, format: "xls", params: { include: "members_only" }

        assert_response :success
        today = RacingAssociation.current.effective_today
        assert_equal("filename=\"people_#{today.year}_#{today.month}_#{today.day}.xls\"", @response.headers["Content-Disposition"], "Should set disposition")
        assert_equal("application/vnd.ms-excel; charset=utf-8", @response.headers["Content-Type"], "Should set content to Excel")
        # FIXME: use send_data
        # assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
      end

      test "export members only to excel promoter" do
        destroy_person_session
        PersonSession.create(FactoryBot.create(:promoter))

        get :index, params: { include: "members_only", excel_layout: "scoring_sheet" }, format: "xls"

        assert_response :success
        assert_equal("filename=\"scoring_sheet.xls\"", @response.headers["Content-Disposition"], "Should set disposition")
        assert_equal("application/vnd.ms-excel; charset=utf-8", @response.headers["Content-Type"], "Should set content to Excel")
        # FIXME: use send_data
        # assert_not_nil(@response.headers['Content-Length'], "Should set content length in headers:\n#{@response.headers.join("\n")}")
      end

      test "export members only to scoring sheet" do
        get :index, format: "xls", params: { include: "members_only", excel_layout: "scoring_sheet" }

        assert_response :success
        assert_equal("filename=\"scoring_sheet.xls\"", @response.headers["Content-Disposition"], "Should set disposition")
        assert_equal("application/vnd.ms-excel; charset=utf-8", @response.headers["Content-Type"], "Should set content to Excel")
        # FIXME: use send_data
        # assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
      end

      test "export print cards to endicia" do
        get :index, format: "xls", params: { include: "print_cards", excel_layout: "endicia" }

        assert_response :success
        assert_equal("filename=\"print_cards.xls\"", @response.headers["Content-Disposition"], "Should set disposition")
        assert_equal("application/vnd.ms-excel; charset=utf-8", @response.headers["Content-Type"], "Should set content to Excel")
        # FIXME: use send_data
        # assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
      end
    end
  end
end
