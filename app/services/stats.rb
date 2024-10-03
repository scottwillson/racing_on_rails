# frozen_string_literal: true

module Stats
  def self.racer_days_by_discipline(years)
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
    Rails.cache.write("racer_days_by_discipline", chart_data, expires_in: 12.hours)
    chart_data
  end
end
