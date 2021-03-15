# frozen_string_literal: true

module Events
  module Results
    extend ActiveSupport::Concern

    included do
      before_destroy :validate_no_results

      scope :include_results, lambda {
        includes(races: [:category, { results: :team }])
      }

      scope :include_child_results, lambda {
        includes(children: { races: [:category, { results: :team }] })
      }

      scope :most_recent_with_recent_result, lambda { |weeks|
        includes(races: %i[category results])
          .includes(:parent)
          .where.not(type: "Event")
          .where.not(type: nil)
          .where("events.date >= ?", weeks)
          .where("id in (select event_id from results where competition_result = false and team_competition_result = false)")
          .order("updated_at desc")
      }

      scope :with_recent_results, lambda { |weeks|
        includes(parent: :parent)
          .where.not(type: "Event")
          .where.not(type: nil)
          .where("events.date >= ?", weeks)
          .where("id in (select event_id from results where competition_result = false and team_competition_result = false)")
          .order("updated_at desc")
      }

      scope :discipline, lambda { |discipline|
        if discipline
          if discipline == Discipline["road"]
            where discipline: [discipline.name, "Circuit", "Road/Gravel"]
          else
            where discipline: discipline.name
          end
        end
      }

      # Return [weekly_series, events] that have results
      def self.find_all_with_results(year = Time.zone.today.year, discipline = nil)
        # Maybe this should be its own class, since it has knowledge of Event and Result?

        # Faster to load IDs and pass to second query than to use join or subselect
        event_ids = Result.where(year: year).pluck(:event_id).uniq
        events = Event
                 .includes(parent: :parent)
                 .where(id: event_ids)
                 .distinct

        events = events.discipline(discipline)

        ids = events.map(&:root_id).uniq
        Event.includes(children: [:races, { children: :races }]).where(id: ids)
      end
    end

    def validate_no_results
      if any_results?
        errors.add :results, "Cannot destroy event with results"
        throw :abort
      end

      if any_results_including_children?
        errors.add :results, "Cannot destroy event with children with results"
        throw :abort
      end
    end

    # Result updated_at should propagate to Event updated_at but does not yet
    def results_updated_at
      Result.where(race_id: races.map(&:id)).maximum(:updated_at)
    end

    # Will return false-positive if there are only overall series results, but those should only exist if there _are_ "real" results.
    # The results page should show the results in that case.
    def any_results?
      races.any?(&:any_results?)
    end

    # Will return false-positive if there are only overall series results, but those should only exist if there _are_ "real" results.
    # The results page should show the results in that case.
    def any_results_including_children?
      races.any?(&:any_results?) || children.any?(&:any_results_including_children?)
    end

    # Returns only the children with +results+
    def children_with_results
      children.select(&:any_results_including_children?)
    end

    # Returns only the Races with +results+
    def races_with_results
      races.select(&:any_results?)
    end

    # Helper method for as_json
    def sorted_races
      races.sort
    end
  end
end
