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
        Person.destroy_all

        FactoryGirl.create(:person, :name => "", :email => "sixhobsons@comcast.net", :home_phone => "(503) 223-3343", :member => false, :member_from => nil, :member_to => nil)
        FactoryGirl.create(:person, :name => "Molly Cameron", :team_name => "Vanilla", :member_from => Time.zone.local(1999).beginning_of_year, :member_to => Time.zone.now.end_of_year, :gender => "F", :road_number => "202")
        FactoryGirl.create(:person, :name => "Kevin Con'Condron", :license => "576", :team_name => "Gentle Lovers", :member_from => Time.zone.local(2000), :member_to => Time.zone.local(2011).end_of_year, :email => "kc@example.com")
        FactoryGirl.create(:person, :name => "Bob Jones", :member_from => Time.zone.local(2009), :member_to => Time.zone.local(2009).end_of_year, :email => "member@example.com")
        FactoryGirl.create(:person, :name => "Mark Matson", :license => "576", :member_from => Time.zone.local(1999), :member_to => Time.zone.now.end_of_year, :team_name => "Kona", :email => "mcfatson@gentlelovers.com", :gender => "M", :road_number => "340")
        administrator = FactoryGirl.create(:administrator, :member_from => nil, :member_to => nil)
        PersonSession.create(administrator)
        FactoryGirl.create(:person, :name => "Alice Pennington", :team_name => "Gentle Lovers", :member_from => Time.zone.local(1999), :member_to => Time.zone.now.end_of_year, :road_number => "230", :gender => "F")
        FactoryGirl.create(:person, :name => "Non Results", :member_from => nil, :member_to => nil)
        FactoryGirl.create(:person, :name => "Brad Ross", :member_from => nil, :member_to => nil)
        
        tonkin = FactoryGirl.create(:person, :singlespeed_number => "409", :track_number => "765", :name => "Erik Tonkin", :member_from => Time.zone.local(1999), :member_to => Time.zone.now.end_of_year, :date_of_birth => Time.zone.local(1982, 9, 10), :street => "127 SE Lambert", :city => "Portland", :state => "OR", :zip => "19990", :home_phone => "415 221-3773", :gender => "M", :road_category => "1", :track_category => "5", :road_number => "102", :license => "7123811", :team_name => "Kona")
        tonkin.race_numbers.create!(:discipline => Discipline[:singlespeed], :value => "410")

        weaver = FactoryGirl.create(:person, :name => "Ryan Weaver", :email => "hotwheels@yahoo.com", :gender => "M", :road_number => "341", :xc_number => "437", :team_name => "Gentle Lovers")
        weaver.race_numbers.create!(:discipline => Discipline[:road], :value => "888")
        weaver.race_numbers.create!(:discipline => Discipline[:road], :value => "999")

        get(:index, :format => 'xls', :include => 'all')

        assert_response :success
        today = RacingAssociation.current.effective_today
        assert_equal("filename=\"people_#{today.year}_#{today.month}_#{today.day}.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
        assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers["Content-Type"], 'Should set content to Excel')
        # FIXME use send_data
        assert_equal(11, assigns['people'].size, "People export size")
        
        # Some dates are wrong. Leaving as-is while fixing apostrophes.
        expected_body = [
          "license	first_name	last_name	team_name	member_from	member_to	ccx_only	print_card	card_printed_at	membership_card	date_of_birth	occupation	street	city	state	zip	wants_mail	email	wants_email	home_phone	work_phone	cell_fax	gender	road_category	track_category	ccx_category	mtb_category	dh_category	ccx_number	dh_number	road_number	singlespeed_number	track_number	xc_number	notes	volunteer_interest	official_interest	race_promotion_interest	team_interest	created_at	updated_at\n",
          "						0	0		0							0	sixhobsons@comcast.net	0	(503) 223-3343																0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n",
          "	Molly	Cameron	Vanilla	12/31/1998	12/31/#{Time.zone.today.year}	0	0		0							0		0				F								202					0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n",
          "576	Kevin	Con'Condron	Gentle Lovers	12/31/1999	12/31/#{Time.zone.today.year - 1}	0	0		0							0	kc@example.com	0																	0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n",
          "	Bob	Jones		12/31/2008	12/31/2009	0	0		0							0	member@example.com	0																	0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n",
          "576	Mark	Matson	Kona	12/31/1998	12/31/#{Time.zone.today.year}	0	0		0							0	mcfatson@gentlelovers.com	0				M								340					0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n",
          "	Candi	Murray				0	0		0							0	admin@example.com	0	(503) 555-1212																0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n",
          "	Alice	Pennington	Gentle Lovers	12/31/1998	12/31/#{Time.zone.today.year}	0	0		0							0		0				F								230					0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n",
          "	Non	Results				0	0		0							0		0																	0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n",
          "	Brad	Ross				0	0		0							0		0																	0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n",
          "7123811	Erik	Tonkin	Kona	12/31/1998	12/31/#{Time.zone.today.year}	0	0		0	09/09/1982		127 SE Lambert	Portland	OR	19990	0		0	415 221-3773			M	1	5						102	409				0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n",
          "	Ryan	Weaver	Gentle Lovers	12/31/1999	12/30/#{Time.zone.today.year}	0	0		0							0	hotwheels@yahoo.com	0				M								341			437		0	0	0	0	#{Time.zone.now.to_s(:mdY)}	#{Time.zone.now.to_s(:mdY)}\n"
          ].reverse
   
        @response.body.lines.each do |line|
          assert_equal expected_body.pop, line
        end
        
        #assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
      end
  
      def test_export_to_excel_with_date
        get(:index, :format => 'xls', :include => 'all', :date => "2008-12-31")

        assert_response :success
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

