module Admin
  class StatsController < Admin::AdminController
    def index
      @years = %w[2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024]
      @racer_days_by_discipline = Stats.racer_days_by_discipline(@years)
      @racers_by_discipline = Stats.racers_by_discipline(@years)
      @total_racer_days = Stats.total_racer_days(@years)
      @racers_by_gender = Stats.racers_by_gender(@years)
      @total_juniors = Stats.total_juniors(@years)
      @memberships = Stats.memberships(@years)
    end

    def nopandemic
      @years = %w[2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2021 2022 2023 2024]
      @racer_days_by_discipline = Stats.racer_days_by_discipline(@years)
      @racers_by_discipline = Stats.racers_by_discipline(@years)
      @total_racer_days = Stats.total_racer_days(@years)
      @total_juniors = Stats.total_juniors(@years)
      @memberships = Stats.memberships(@years)
    end
  end
end
