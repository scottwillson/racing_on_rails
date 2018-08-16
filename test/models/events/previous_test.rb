# frozen_string_literal: true

require "test_helper"

module Events
  # :stopdoc:
  class PreviousTest < ActiveSupport::TestCase
    test "#previous and #previous?" do
      assert !Event.new.previous?
      assert_nil Event.new.previous_year

      promoter = FactoryBot.create(:person, name: "David Saltzman")
      copperoplis = FactoryBot.create(:event, name: "Copperopolis", date: 1.year.ago, promoter: promoter)
      event = FactoryBot.create(:event, name: "Tabor")
      assert !event.previous?, "Did not expect previous event #{event.previous_year.try(:name)}"
      assert_nil event.previous_year

      event = FactoryBot.create(:event, name: "Copperopolis")
      assert event.previous?
      assert_equal copperoplis, event.previous_year
    end

    test "#previous fuzzy match" do
      copperoplis = FactoryBot.create(:event, name: "Copperopolis RR", date: 1.year.ago)
      event = FactoryBot.create(:event, name: "Copperopolis")
      assert event.previous?
      assert_equal copperoplis, event.previous_year
    end
  end
end
