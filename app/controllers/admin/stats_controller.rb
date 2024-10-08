module Admin
  class StatsController < Admin::AdminController
    def index
      @years = Stats.years
      @racer_days_by_discipline = Stats.racer_days_by_discipline
      @total_racer_days = Stats.total_racer_days
      @racers_by_discipline = Stats.racers_by_discipline
      @memberships = Stats.memberships
      @total_juniors = Stats.total_juniors
    end
  end
end
