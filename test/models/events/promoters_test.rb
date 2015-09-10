require File.expand_path("../../../test_helper", __FILE__)

module Events
  # :stopdoc:
  class PromoterTest < ActiveSupport::TestCase
    test "editable by and editable_by?" do
      event_1 = FactoryGirl.create(:event)
      event_2 = FactoryGirl.create(:event)

      racer = FactoryGirl.create(:person)
      assert_equal [], Event.editable_by(racer), "Random person can't edit any events"
      assert !event_1.editable_by?(racer)
      assert !event_2.editable_by?(racer)

      editor = FactoryGirl.create(:person)
      event_1.editors << editor

      assert_equal [ event_1 ], Event.editable_by(event_1.promoter), "Promoter can edit own events"
      assert_equal [ event_2 ], Event.editable_by(event_2.promoter), "Promoter can edit own events"
      assert_equal [ event_1 ], Event.editable_by(editor), "Editor can edit own events"

      assert event_1.editable_by?(event_1.promoter)
      assert !event_1.editable_by?(event_2.promoter)
      assert event_1.editable_by?(editor)
      assert !event_2.editable_by?(event_1.promoter)
      assert event_2.editable_by?(event_2.promoter)
      assert !event_2.editable_by?(editor)

      administrator = FactoryGirl.create(:administrator)
      assert_equal_enumerables Event.all, Event.editable_by(administrator), "Administrator can edit all events"
      assert event_1.editable_by?(administrator)
      assert event_1.editable_by?(administrator)
      assert event_1.editable_by?(administrator)
      assert event_2.editable_by?(administrator)
      assert event_2.editable_by?(administrator)
      assert event_2.editable_by?(administrator)

      assert_equal [], Event.editable_by(nil), "nil can't edit any events"
      assert !event_1.editable_by?(nil)
      assert !event_2.editable_by?(nil)
    end
  end
end
