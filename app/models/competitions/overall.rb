module Competitions
  # Common superclass for Omniums and Series standings.
  # Easy to miss override: Overall results only include members
  class Overall < Competition
    include Competitions::Calculations::CalculatorAdapter

   validates_presence_of :parent
   after_create :add_source_events

   def self.parent_event_name
     self.name
   end

    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          parent = ::MultiDayEvent.year(year).where(name: parent_event_name).first

          overall = parent.try(:overall)
          if parent && parent.any_results_including_children?
            unless parent.overall
              # parent.create_overall will create an instance of Overall, which is probably not what we want
              overall = self.new(parent_id: parent.id, date: parent.date)
              overall.save!
              parent.overall = overall
            end
            overall.set_date
            overall.delete_races
            overall.create_races
            overall.calculate!
          end
        end
      end
      true
    end

    def default_name
      "Series Overall"
    end

    # TODO Remove dupe?
    def add_source_events
      parent.children.each do |source_event|
        source_events << source_event
      end
    end

    def source_events?
      true
    end

    def source_results_query(race)
      super.
      where("races.category_id in (?)", category_ids_for(race))
    end

    # Only members can score points?
    def members_only?
      false
    end

    def maximum_events(race)
      6
    end
  end
end
