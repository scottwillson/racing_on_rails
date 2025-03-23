module Admin
  class StatsController < Admin::AdminController
    def index
      @years = if params[:nopandemic] == "true"
                 %w[2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2021 2022 2023 2024 2025]
               else
                 %w[2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025]
               end
      @racer_days_by_discipline = Stats.cache_and_query(:racer_days_by_discipline, @years)
      @racer_days_gender_ratio = Stats.cache_and_query(:racer_days_gender_ratio, @years)
      @racers_by_discipline = Stats.cache_and_query(:racers_by_discipline, @years)
      @junior_racer_days = Stats.cache_and_query(:junior_racer_days, @years)
      @total_racers = Stats.cache_and_query(:total_racers, @years)
      @racer_days_by_gender = Stats.cache_and_query(:racer_days_by_gender, @years)
      @racers_by_gender = Stats.cache_and_query(:racers_by_gender, @years)
      @total_racer_days = Stats.cache_and_query(:total_racer_days, @years)
      @gender_ratio = Stats.cache_and_query(:gender_ratio, @years)
      @total_juniors = Stats.cache_and_query(:total_juniors, @years)
      @memberships = Stats.cache_and_query(:memberships, @years)
    end
  end
end
