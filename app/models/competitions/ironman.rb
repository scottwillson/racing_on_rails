module Competitions
  # Who has done the most events? Just counts starts/appearences in results. Not pefect -- some events
  # are probably over-counted.
  class Ironman < Competition
    include Competitions::Calculations::CalculatorAdapter

    def friendly_name
      'Ironman'
    end

    def points_for(source_result)
      1
    end

    def break_ties?
      false
    end

    def dnf?
      true
    end

    def notes
      "The Ironman Competition is a 'just for fun' record of the number of events riders do. There is no prize just identification of riders who need to get a life."
    end
    
    def source_results_query(race)
      super.where("events.ironman" => true)
    end
  end
end
