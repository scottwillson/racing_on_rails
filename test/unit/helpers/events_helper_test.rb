require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class EventsHelperTest < ActionView::TestCase
  def test_link_to_event_email
    event = SingleDayEvent.new
    assert link_to_event_email(event).blank?, "No promoter or contact info should be blank"
    
    promoter = Person.new
    event.promoter = promoter
    assert link_to_event_email(event).blank?, "No promoter or contact info should be blank"
    
    promoter.name = "Velo Bob"
    assert link_to_event_email(event), "No promoter or contact info should be blank"
    assert_match(/^Velo Bob$/, link_to_event_email(event), "Promoter name only")
    
    promoter.email = "bob@velopromo.com"
    assert link_to_event_email(event), "No promoter or contact info should be blank"
    assert_match(/Velo Bob/, link_to_event_email(event), "Promoter name and email")
    assert_match(/href="mailto:bob@velopromo.com"/, link_to_event_email(event), "Promoter name and email")
    
    promoter.name = ""
    assert link_to_event_email(event), "No promoter or contact info should be blank"
    assert_match(/href="mailto:bob@velopromo.com"/, link_to_event_email(event), "Promoter email")
    assert_match(/>bob@velopromo.com<\/a>/, link_to_event_email(event), "Promoter email")

    event = SingleDayEvent.new(:email => "copperopolis@velopromo.com")
    assert_match(/href="mailto:copperopolis@velopromo.com"/, link_to_event_email(event), "Event email and no promoter")
    
    promoter = Person.new
    event.promoter = promoter
    assert_match(/href="mailto:copperopolis@velopromo.com"/, link_to_event_email(event), "Event email and blank promoter")
    
    promoter.name = "Velo Bob"
    assert_match(/Velo Bob/, link_to_event_email(event), "Event email and promoter name only")
    assert_match(/href="mailto:copperopolis@velopromo.com"/, link_to_event_email(event), "Event email and promoter name only")
    
    promoter.email = "bob@velopromo.com"
    assert_match(/Velo Bob/, link_to_event_email(event), "Event email and promoter email")
    assert_match(/href="mailto:copperopolis@velopromo.com"/, link_to_event_email(event), "Event email and promoter email")
    
    promoter.name = ""
    assert_match(/href="mailto:copperopolis@velopromo.com"/, link_to_event_email(event), "Event email and promoter email and no promoter name")
    assert_match(/>copperopolis@velopromo.com<\/a>/, link_to_event_email(event), "Event email and promoter email and no promoter name")
  end

  def test_link_to_event_phone
    event = SingleDayEvent.new
    link_to_event_phone event

    promoter = Person.new
    event.promoter = promoter
    assert link_to_event_phone(event).blank?, "No promoter or contact info should be blank"

    event.promoter.home_phone = "717 655-0000"
    assert_equal "717 655-0000", link_to_event_phone(event), "Promoter home phone"

    event.phone = "212 333-1010"
    assert_equal "212 333-1010", link_to_event_phone(event), "Event phone"

    event.promoter.home_phone = nil
    assert_equal "212 333-1010", link_to_event_phone(event), "Event phone"

    event.promoter = nil
    assert_equal "212 333-1010", link_to_event_phone(event), "Event phone"
  end
end
