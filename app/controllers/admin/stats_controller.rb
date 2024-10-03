module Admin
  class StatsController < Admin::AdminController
    def index
      @chart_data = []
      Discipline.pluck(:name).each do |discipline|
        @chart_data.push({ name: discipline, data: [] })
      end
      %w[2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024].each do |year|
        res = Result.joins(:event).where(events: { year: year, type: "SingleDayEvent" })
                    .where(competition_result: false, team_competition_result: false)
                    .where.not(person_id: nil).group(:discipline).count
        @chart_data.each do |data|
          if res[data[:name]].nil?
            data[:data].push(0)
          else
            data[:data].push(res[data[:name]])
          end
        end
      end
    end
  end
end
