# frozen_string_literal: true

module Stats
  def self.years
    %w[2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024]
  end

  def self.racer_days_by_discipline
    return Rails.cache.read("racer_days_by_discipline") if Rails.cache.read("racer_days_by_discipline").present?

    chart_data = []
    Discipline.pluck(:name).each do |discipline|
      chart_data.push({ name: discipline, data: [] })
    end
    years.each do |year|
      res = Result.joins(:event).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).group(:discipline).count
      chart_data.each do |data|
        if res[data[:name]].nil?
          data[:data].push(0)
        else
          data[:data].push(res[data[:name]])
        end
      end
    end
    chart_data.each do |data|
      if data[:data].sum.zero?
        chart_data.delete(data)
      end
    end
    Rails.cache.write("racer_days_by_discipline", chart_data, expires_in: 12.hours)
    chart_data
  end

  def self.total_racer_days
    return Rails.cache.read("total_racer_days") if Rails.cache.read("total_racer_days").present?

    chart_data = [{ name: "Total Racer Days", data: [] }]
    years.each do |year|
      res = Result.joins(:event).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).count
      chart_data[0][:data].push(res)
    end
    Rails.cache.write("total_racer_days", chart_data, expires_in: 12.hours)
    chart_data
  end
end
