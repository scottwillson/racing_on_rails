class AddObraHomepagePartials < ActiveRecord::Migration
  def up
    if RacingAssociation.current.short_name == "OBRA"
      Person.current = Person.find_by_name("Scott Willson")
      home = Page.find_by_title("Home Page") || Page.new(:title => "Home Page", :slug => "home")
      home.body = home_html.strip
      home.save!
      
      [ "ads", "links", "associated" ].each do |title|
        page = Page.find_by_title(title) || home.children.build(:title => title)
        page.body = send("#{title}_html").strip
        page.save!
      end
    end
  end

  def down
  end
  
  def ads_html
    <<-END
    <div class="row-fluid">
      <div class="span3">
        <a href="http://issuu.com/castelli-cycling/docs/serviziocorse_2013_us" class="ad" onclick="javascript: pageTracker._trackPageview(&#x27;issuu.com/castelli-cycling/docs/serviziocorse_2013_us&#x27;);"><img class="ad" alt="2013_catalog" src="http://www.obra.org/images/ads/2013_catalog.jpg" /></a>
      </div>
      <div class="span3">
        <a href="http://castelli-cycling.com/it/home/" class="ad" onclick="javascript: pageTracker._trackPageview(&#x27;/outgoing/castelli-cycling.com/&#x27;);"><img class="ad" alt="Castelli" src="http://www.obra.org/images/ads/castelli.gif" /></a>
      </div>
      <div class="span3">
        <a href="http://www.bicycleattorney.com/" class="ad" onclick="javascript: pageTracker._trackPageview(&#x27;/outgoing/bicycleattorney.com&#x27;);"><img class="ad" alt="Mike_colbach" src="http://www.obra.org/images/ads/mike_colbach.gif" /></a>
      </div>
      <div class="span3">
        <a href="http://www.rolfprima.com/" class="ad" onclick="javascript: pageTracker._trackPageview(&#x27;/outgoing/rolfprima.com/&#x27;);"><img class="ad" alt="Rolf_prima" src="http://www.obra.org/images/ads/rolf_prima.gif" /></a>
      </div>
    </div>
  
    <div class="row-fluid">
      <div class="span3">
        <a href="http://www.upperechelonfitness.com/" class="ad" onclick="javascript: pageTracker._trackPageview(&#x27;/outgoing/upperechelonfitness.com&#x27;);"><img class="ad" alt="Upper_echelon" src="http://www.obra.org/images/ads/upper_echelon.gif" /></a>
      </div>
      <div class="span3">
        <a href="http://obra.org/OWPS" class="ad" onclick="javascript: pageTracker._trackPageview(&#x27;/outgoing/obra.org/OWPS&#x27;);"><img class="ad" alt="Owps" src="http://www.obra.org/images/ads/owps.gif" /></a>
      </div>
      <div class="span3">
        <a href="http://obra.org/membership/new.html" class="ad" onclick="javascript: pageTracker._trackPageview(&#x27;/membership/new.html&#x27;);"><img class="ad" alt="Join" src="http://www.obra.org/images/ads/join.gif" /></a>
      </div>
    </div>
    END
  end

  def links_html
    <<-END
    <div class="well">
      <div class="row-fluid">
        <div class="span4">
          <h3>Contacts</h3>
          <ul>
            <li><a href="http://www.obra.org/contact.html">Contact OBRA</a></li>
            <li><a href="http://www.obra.org/board_of_directors.html">Board of Directors</a></li>
            <li><a href="http://obra.org/mailing_lists">Email List</a></li>
            <li><a href="http://www.obra.org/media/">Media Information</a></li>
            <li><a href="http://www.obra.org/coaches.html">Coaches</a></li>
            <li><a href="http://app.obra.org/teams">Teams</a></li>
            <li><a href="https://obra.org/store">OBRA Store</a></li>
          </ul>
        </div>
        <div class="span4">
          <h3>Competitions</h3>
          <ul>
            <li><a href="http://obra.org/bar">Best All-around Rider</a> (BAR)</li>
            <li><a href="http://obra.org/obra_women_prestige_series">OBRA Women's Prestige Race Series</a></li>
            <li><a href="http://www.crosscrusade.com">Cross Crusade Series</a></li>
            <li><a href="http://cyclocross.gp">Grand Prix Tina Brubaker</a></li>
            <li><a href="http://obra.org/ironman">Ironman</a></li>
            <li><a href="http://obra.org/oregon_cup">Oregon Cup</a></li>
            <li><a href="http://www.obra.org/junior_cyclocross_series/">OBRA Junior Cyclocross Series</a></li>
            <li>OBRA TT Cup - <a href="http://www.obra.org/pdfs/TTCupRules2013.pdf">Rules</a>, <a href="https://www.athletepath.com/obra-time-trial-series/2013-obra-tt-standings/results">Results</a>, <a href="http://www.obra.org/pdfs/TTCupCalendar2013.pdf">Schedule</a></li>
            <li><a href="http://www.mudslingerevents.com/2012-oregon-xc-mtb-series/">Oregon XC Series</a></li>
          </ul>
        </div>
        <div class="span4">
          <h3><a href="http://www.obra.org/forms/#racer">Racers</a></h3>
          <ul>
            <li>
              <a href="http://www.obra.org/pdfs/membership_app.pdf">Membership Application</a>:
              <a href="http://www.obra.org/pdfs/membership_app.pdf">PDF</a>,
              <a href="http://obra.org/membership/new">Online</a>
            </li>
            <li>
              <a href="https://obra.org/products/4/line_items/create">Team Membership Application</a>: 
              <a href="http://www.obra.org/pdfs/club_membership_app.pdf">PDF</a>
              <a href="https://obra.org/products/4/line_items/create">Online</a>
            </li>
            <li><a href="http://www.obra.org/pdfs/waiver.pdf">Race Release</a></li>
            <li><a href="https://obra.org/store">OBRA Store (registration, jerseys, dues &amp; more)</a></li>
            <li>Rules: <a href="http://www.obra.org/pdfs/2013RacingRules.pdf">Racing</a>, 
              <a href="http://www.obra.org/pdfs/2011adminrules.pdf">Administrative</a>, 
              <a href="http://www.obra.org/upgrade_rules.html">Upgrade</a></li>
            <li><a href="/people">Search</a></li>
            <li><a href="http://www.obra.org/forms/">More...</a></li>
          </ul>
        </div>
      </div>
      <div class="row-fluid">
        <div class="span4">
          <h3><a href="http://www.obra.org/forms/#promoter">Promoters</a></h3>
          <ul>
            <li><a href="http://www.obra.org/pdfs/insurance_app.pdf">Insurance Application</a></li>
            <li><a href="http://www.obra.org/pdfs/agreement_letter.pdf">Letter of Agreement</a></li>
            <li><a href="http://www.obra.org/forms/equipment_request.xls">Equipment Request Form</a></li>
            <li><a href="http://obra.org/online_registration">Online Registration</a></li>
            <li><a href="http://www.obra.org/forms/">More...</a></li>
          </ul>
        </div>
        <div class="span4">
          <h3><a href="http://app.obra.org/track">Alpenrose Velodrome</a></h3>
          <ul>
            <li><a href="http://obra.org/products/27/line_items/create">Donate to Repair Fund</a></li>
            <li><a href="http://www.obra.org/track/information/">Information</a></li>
            <li><a href="http://www.obra.org/track/records/">Records</a></li>
            <li><a href="http://app.obra.org/track/schedule">Schedule</a></li>
          </ul>
        </div>
        <div class="span4">
          <h3><a href="http://www.obra.org/links.html">Links</a></h3>
          <ul>
            <li><a href="http://www.obra.org/links.html#racing_orgs">Other Racing Organizations and Calendars</a></li>
            <li><a href="http://www.obra.org/links.html#news_info">News and Information</a></li>
            <li><a href="http://www.obra.org/links.html#photos">Photographs</a></li>
            <li><a href="http://www.obra.org/links.html">More...</a></li>
          </ul>
        </div>
      </div>
    </div>
    END
  end
  
  def associated_html
    <<-END
    <div class="row-fluid">
      <div class="span12 associated">
        <a href="http://www.easystreet.com/" class="image"><img alt="Hosted_by_easystreet" height="80" src="http://www.obra.org/images/logos/hosted_by_easystreet.gif" width="80" /></a>
        <a href="http://www.uscx.org/" class="image"><img alt="Uscx_final" height="90" src="http://www.obra.org/images/logos/USCX_final.gif" width="229" /></a>
        <a href="http://www.nabra.us/" class="image"><img alt="Nabra+logo_sm" height="100" src="http://www.obra.org/images/logos/NABRA+Logo_SM.gif" width="196" /></a>  
        <a href="http://www.imba.com/" class="image"><img alt="Imba" height="65" src="http://www.obra.org/images/logos/imba.gif" width="136" /></a>
        <a href="http://www.bta4bikes.org/" class="image"><img alt="Bta_supporter_12" height="90" src="http://www.obra.org/images/logos/BTA_supporter_12.gif" width="86" /></a>
      </div>
    </div>
    END
  end
  
  def home_html
    <<-END
    <div class="container-fluid home">
      <%= render "photo", 
            :photo => @photo, 
            :most_recent_event_with_recent_result => @most_recent_event_with_recent_result, 
            :weeks_of_recent_results => @home.weeks_of_recent_results %>

      <div class="row-fluid">
        <div class="span6">
          <%= render_page "home/upcoming_events", :upcoming_events => @upcoming_events %>
        </div>
        <div class="span6">
          <%= render_page "home/recent_results", 
                :events_with_recent_results => @events_with_recent_results, 
                :weeks_of_recent_results => @home.weeks_of_recent_results %>
        </div>
      </div>
      <%= render_page "home/ads" %>
      <%= render_page "home/links" %>
      <%= render_page "home/associated" %>
    </div>
    END
  end
end
