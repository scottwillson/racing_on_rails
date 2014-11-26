require "test_helper"

module Competitions
  # :stopdoc:
  class BlindDateAtTheDairyOverallTest < ActiveSupport::TestCase
    test "calculate" do
      Timecop.travel(2014) do
        series = Series.create_for_every!(
          "Wednesday",
          start_date: Date.new(2014, 9, 10), 
          end_date: Date.new(2014, 10, 8), 
          name: "Blind Date at the Dairy"
        )
        
        series.children.each do |event|
          race = FactoryGirl.create(:race, event: event)
          FactoryGirl.create(:result, event: event, race: race, place: "1")
        end
      
        BlindDateAtTheDairyOverall.calculate!
      end
    end
  end
end
