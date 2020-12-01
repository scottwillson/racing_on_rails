# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

module Events
  # :stopdoc:
  class PromoterTest < ActiveSupport::TestCase
    test "editable by and editable_by?" do
      event_1 = FactoryBot.create(:event)
      event_2 = FactoryBot.create(:event)

      racer = FactoryBot.create(:person)
      assert_equal [], Event.editable_by(racer), "Random person can't edit any events"
      assert_not event_1.editable_by?(racer)
      assert_not event_2.editable_by?(racer)

      editor = FactoryBot.create(:person)
      event_1.editors << editor

      assert_equal [event_1], Event.editable_by(event_1.promoter), "Promoter can edit own events"
      assert_equal [event_2], Event.editable_by(event_2.promoter), "Promoter can edit own events"
      assert_equal [event_1], Event.editable_by(editor), "Editor can edit own events"

      assert event_1.editable_by?(event_1.promoter)
      assert_not event_1.editable_by?(event_2.promoter)
      assert event_1.editable_by?(editor)
      assert_not event_2.editable_by?(event_1.promoter)
      assert event_2.editable_by?(event_2.promoter)
      assert_not event_2.editable_by?(editor)

      administrator = FactoryBot.create(:administrator)
      assert_equal_enumerables Event.all, Event.editable_by(administrator), "Administrator can edit all events"
      assert event_1.editable_by?(administrator)
      assert event_1.editable_by?(administrator)
      assert event_1.editable_by?(administrator)
      assert event_2.editable_by?(administrator)
      assert event_2.editable_by?(administrator)
      assert event_2.editable_by?(administrator)

      assert_equal [], Event.editable_by(nil), "nil can't edit any events"
      assert_not event_1.editable_by?(nil)
      assert_not event_2.editable_by?(nil)
    end
  end
end
