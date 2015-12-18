require "test_helper"

module Events
  # :stopdoc:
  class PreviousTest < ActiveSupport::TestCase
    test "#previous and #previous?" do
      assert !Event.new.previous?
      assert_nil Event.new.previous

      copperoplis = FactoryGirl.create(:event, name: "Copperopolis", date: 1.year.ago)
      event = FactoryGirl.create(:event, name: "Tabor")
      assert !event.previous?
      assert_nil event.previous

      event = FactoryGirl.create(:event, name: "Copperopolis")
      assert event.previous?
      assert_equal copperoplis, event.previous
    end
  end
end
