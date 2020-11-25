# frozen_string_literal: true

# All categories' results in a time trial by time
# Adds +combined_results+ if Time Trial Event.
# Destroy +combined_results+ if they exist, but should not
# All the calculation happens synchronously, which isn't ideal. Logic overlaps heavily with Competition as well.
class CombinedTimeTrialResults < Event
  attribute :auto_combined_results, :boolean, default: -> { false }

  def self.calculate!
    # ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
    #   events = requires_combined_results_events
    #   events.each do |e|
    #     combined_results = create_combined_results(e)
    #     combined_results.calculate!
    #   end
    #
    #   (has_combined_results_events - events).each do |e|
    #     destroy_combined_results e
    #   end
    # end
  end

  def self.requires_combined_results_events
    event_ids = Result
                .joins(:event)
                .where("place is not null and cast(place as signed) > 0")
                .where("results.time > 0")
                .where(events: { discipline: "Time Trial" })
                .pluck(:event_id)
                .uniq

    Event.find(event_ids)
  end

  def self.has_combined_results_events
    Event.where("id in (select parent_id from events where type='CombinedTimeTrialResults')")
  end

  def self.destroy_combined_results(event)
    # if event.combined_results
    #   event.combined_results.destroy_races
    #   event.combined_results.reload.destroy
    #   event.combined_results = nil
    # end
  end

  def self.allows_combined_results?(event)
    event.discipline == "Time Trial"
  end

  def self.create_combined_results(event)
    # event.create_combined_results(name: "Combined") unless event.combined_results
    # event.combined_results
  end

  def default_bar_points
    0
  end

  def default_discipline
    "Time Trial"
  end

  def default_ironman
    false
  end

  def should_calculate?
    false
    # parent.results_updated_at && (results_updated_at.nil? || parent.results_updated_at > results_updated_at)
  end

  def calculate!
    return false

    transaction do
      destroy_races
      combined_by_time_race = races.create!(category: Category.find_or_create_by(name: "Combined"))
      source_results = select_source_results
      create_combined_by_time_results combined_by_time_race, source_results
      combined_by_time_race.place_results_by_time
    end

    ApplicationController.expire_cache

    true
  end

  def select_source_results
    parent.races.map do |race|
      race.results.select(&:finished_time_trial?)
    end
          .flatten
          .uniq { |r| [r.person_id, r.time] }
  end

  def create_combined_by_time_results(combined_race, source_results)
    source_results.each do |result|
      combined_race.results.create!(
        person: result.person,
        team: result.team,
        time: result.time,
        category: result.race.category
      )
    end
  end
end
