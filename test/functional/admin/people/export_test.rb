require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  module People
    class ExportTest < ActionController::TestCase
      tests Admin::PeopleController
      
      def setup
        super
        create_administrator_session
        use_ssl

        FactoryGirl.create(:discipline, :name => "Cyclocross")
        FactoryGirl.create(:discipline, :name => "Downhill")
        FactoryGirl.create(:discipline, :name => "Mountain Bike")
        FactoryGirl.create(:discipline, :name => "Road")
        FactoryGirl.create(:discipline, :name => "Singlespeed")
        FactoryGirl.create(:discipline, :name => "Track")
        FactoryGirl.create(:number_issuer)
      end

      def test_export_to_excel
        tonkin = FactoryGirl.create(:person, :singlespeed_number => "409", :track_number => "765")
    
        RaceNumber.create!(:person => tonkin, :discipline => Discipline[:singlespeed], :value => "410")

        weaver = FactoryGirl.create(:person)
        RaceNumber.create!(:person => weaver, :discipline => Discipline[:road], :value => "888")
        RaceNumber.create!(:person => weaver, :discipline => Discipline[:road], :value => "999")
        assert_equal(2, weaver.race_numbers(true).size, "Weaver numbers")
    
        get(:index, :format => 'xls', :include => 'all')

        assert_response :success
        today = RacingAssociation.current.effective_today
        assert_equal("filename=\"people_#{today.year}_#{today.month}_#{today.day}.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
        assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers["Content-Type"], 'Should set content to Excel')
        # FIXME use send_data
        # assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
        assert_equal(3, assigns['people'].size, "People export size")
        expected_body = %Q{license	first_name	last_name	team_name	member_from	member_to	ccx_only	print_card	card_printed_at	membership_card	date_of_birth	occupation	street	city	state	zip	wants_mail	email	wants_email	home_phone	work_phone	cell_fax	gender	road_category	track_category	ccx_category	mtb_category	dh_category	ccx_number	dh_number	road_number	singlespeed_number	track_number	xc_number	notes	volunteer_interest	official_interest	race_promotion_interest	team_interest	created_at	updated_at
    						0	0		0							0	sixhobsons@comcast.net	0	(503) 223-3343																0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    	Molly	Cameron	Vanilla	01/01/1999	12/31/#{Time.zone.today.year}	0	0		0							0		0				F								202					0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    576	Kevin	Condron	Gentle Lovers	01/01/2000	12/31/#{Time.zone.today.year - 1}	0	0		0							0	kc@example.com	0																	0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    	Bob	Jones		01/01/2009	12/31/2009	0	0		0							0	member@example.com	0																	0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    576	Mark	Matson	Kona	01/01/1999	12/31/#{Time.zone.today.year}	0	0		0							0	mcfatson@gentlelovers.com	0				M								340					0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    	Candi	Murray				0	0		0							0	admin@example.com	0	(503) 555-1212																0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    	Alice	Pennington	Gentle Lovers	01/01/1999	12/31/#{Time.zone.today.year}	0	0		0							0		0				F								230					0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    	Non	Results				0	0		0							0		0																	0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    	Brad	Ross				0	0		0							0		0																	0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    7123811	Erik	Tonkin	Kona	01/01/1999	12/31/#{Time.zone.today.year}	0	0		0	#{30.years.ago.to_date.to_s(:mdY)}		127 SE Lambert	Portland	OR	19990	0		0	415 221-3773			M	1	5						102	409				0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    	Ryan	Weaver	Gentle Lovers	01/01/1999	12/31/#{Time.zone.today.year}	0	0		0							0	hotwheels@yahoo.com	0				M								341			437		0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}
    }
        # FIXME
        # assert_equal expected_body, @response.body, "Excel contents"
      end
  
      def test_export_to_excel_with_date
        get(:index, :format => 'xls', :include => 'all', :date => "2008-12-31")

        assert_response :success
        today = Time.zone.today
        assert_equal("filename=\"people_2008_12_31.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
        assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers["Content-Type"], 'Should set content to Excel')
        # FIXME use send_data
        # assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
        assert_equal(1, assigns['people'].size, "People export size")
      end

      def test_export_members_only_to_excel
        get(:index, :format => 'xls', :include => 'members_only')

        assert_response :success
        today = RacingAssociation.current.effective_today
        assert_equal("filename=\"people_#{today.year}_#{today.month}_#{today.day}.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
        assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
        # FIXME use send_data
        # assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
      end

      def test_export_members_only_to_excel_promoter
        destroy_person_session
        PersonSession.create(FactoryGirl.create(:promoter))
    
        get :index, :format => 'xls', :include => 'members_only', :excel_layout => "scoring_sheet"

        assert_response :success
        today = RacingAssociation.current.effective_today
        assert_equal("filename=\"scoring_sheet.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
        assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
        # FIXME use send_data
        # assert_not_nil(@response.headers['Content-Length'], "Should set content length in headers:\n#{@response.headers.join("\n")}")
      end
    
      def test_export_members_only_to_scoring_sheet
        get(:index, :format => 'xls', :include => 'members_only', :excel_layout => 'scoring_sheet')

        assert_response :success
        assert_equal("filename=\"scoring_sheet.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
        assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
        # FIXME use send_data
        # assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
      end
  
      def test_export_print_cards_to_endicia
        get(:index, :format => "xls", :include => "print_cards", :excel_layout => "endicia")

        assert_response :success
        assert_equal("filename=\"print_cards.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
        assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
        # FIXME use send_data
        # assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
      end
    end
  end
end

