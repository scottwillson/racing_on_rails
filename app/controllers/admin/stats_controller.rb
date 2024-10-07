module Admin
  class StatsController < Admin::AdminController
    def index
      @years = Stats.years
      @racer_days_by_discipline = Stats.racer_days_by_discipline
      @total_racer_days = Stats.total_racer_days
    end
  end
end
