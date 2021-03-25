# frozen_string_literal: true

require_relative "../test_helper"

# :stopdoc:
class EventsHelperTest < ActionView::TestCase
  test "link to event email" do
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
    assert_match(%r{>bob@velopromo.com</a>}, link_to_event_email(event), "Promoter email")

    event = SingleDayEvent.new(email: "copperopolis@velopromo.com")
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
    assert_match(%r{>copperopolis@velopromo.com</a>}, link_to_event_email(event), "Event email and promoter email and no promoter name")
  end

  test "link to event phone" do
    event = SingleDayEvent.new
    event_phone event

    promoter = Person.new
    event.promoter = promoter
    assert event_phone(event).blank?, "No promoter or contact info should be blank"

    event.promoter.home_phone = "717 655-0000"
    assert_equal "717 655-0000", event_phone(event), "Promoter home phone"

    event.phone = "212 333-1010"
    assert_equal "212 333-1010", event_phone(event), "Event phone"

    event.promoter.home_phone = nil
    assert_equal "212 333-1010", event_phone(event), "Event phone"

    event.promoter = nil
    assert_equal "212 333-1010", event_phone(event), "Event phone"
  end
end
