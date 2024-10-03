module Admin
  class StatsController < Admin::AdminController
    def index
      @years = %w[2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024]
      @chart_data = Stats.racer_days_by_discipline(@years)
    end
  end
end
