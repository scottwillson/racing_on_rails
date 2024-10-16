# frozen_string_literal: true

module Stats
  def self.racer_days_by_discipline(years)
    if Rails.cache.read("racer_days_by_discipline").present?
      return Rails.cache.read("racer_days_by_discipline")
    end

    chart_data = racer_days_by_discipline_query(years)
    Rails.cache.write("racer_days_by_discipline", chart_data, expires_in: 12.hours)
    chart_data
  end

  def self.racer_days_by_discipline_query(years)
    chart_data = Discipline.all.map { |discipline| { name: discipline.name, data: [] } }
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
    chart_data
  end

  def self.racers_by_discipline(years)
    if Rails.cache.read("racers_by_discipline").present?
      return Rails.cache.read("racers_by_discipline")
    end

    chart_data = racers_by_discipline_query(years)
    Rails.cache.write("racers_by_discipline", chart_data, expires_in: 12.hours)
    chart_data
  end

  def self.racers_by_discipline_query(years)
    chart_data = Discipline.all.map { |discipline| { name: discipline.name, data: [] } }
    years.each do |year|
      res = Result.joins(:event).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).group(:discipline).distinct.count(:person_id)
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
    chart_data
  end

  def self.memberships(years)
    return Rails.cache.read("memberships") if Rails.cache.read("memberships").present?

    chart_data = [{ name: "Memberships", data: [] }]
    years.each do |year|
      res = LineItem.where(year: year, type: "LineItems::Membership").count
      chart_data[0][:data].push(res)
    end
    Rails.cache.write("memberships", chart_data, expires_in: 12.hours)
    chart_data
  end

  def self.total_racer_days(years)
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

  def self.total_racers(years)
    return Rails.cache.read("total_racers") if Rails.cache.read("total_racers").present?

    chart_data = [{ name: "Racers", data: [] }]
    years.each do |year|
      res = Result.joins(:event).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).distinct
                  .count(:person_id)
      chart_data[0][:data].push(res)
    end
    Rails.cache.write("total_racers", chart_data, expires_in: 12.hours)
    chart_data
  end

  def self.racer_days_by_gender(years)
    return Rails.cache.read("racer_days_by_gender") if Rails.cache.read("racer_days_by_gender").present?

    chart_data = [
      { name: "Not Specified", data: [] },
      { name: "Female", data: [] },
      { name: "Male", data: [] },
      { name: "NB", data: [] }
    ]
    years.each do |year|
      res = Result.joins(:event, :person).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).group("people.gender").count
      chart_data[0][:data].push(res[nil] || 0)
      chart_data[1][:data].push(res["F"] || 0)
      chart_data[2][:data].push(res["M"] || 0)
      chart_data[3][:data].push(res["NB"] || 0)
    end
    Rails.cache.write("racer_days_by_gender", chart_data, expires_in: 12.hours)
    chart_data
  end

  def self.racers_by_gender(years)
    return Rails.cache.read("racers_by_gender") if Rails.cache.read("racers_by_gender").present?

    chart_data = [
      { name: "Not Specified", data: [] },
      { name: "Female", data: [] },
      { name: "Male", data: [] },
      { name: "NB", data: [] }
    ]
    years.each do |year|
      res = Result.joins(:event, :person).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).group("people.gender").distinct.count(:person_id)
      chart_data[0][:data].push(res[nil] || 0)
      chart_data[1][:data].push(res["F"] || 0)
      chart_data[2][:data].push(res["M"] || 0)
      chart_data[3][:data].push(res["NB"] || 0)
    end
    Rails.cache.write("racers_by_gender", chart_data, expires_in: 12.hours)
    chart_data
  end

  def self.gender_ratio(years)
    return Rails.cache.read("gender_ratio") if Rails.cache.read("gender_ratio").present?

    chart_data = [
      { name: "Not Specified", data: [] },
      { name: "Female", data: [] },
      { name: "Male", data: [] },
      { name: "NB", data: [] }
    ]
    years.each do |year|
      res = Result.joins(:event, :person).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).group("people.gender").distinct.count(:person_id)
      counts = [res[nil] || 0, res["F"] || 0, res["M"] || 0, res["NB"] || 0]
      total = counts.sum.to_f
      chart_data[0][:data].push((counts[0] / total).round(2))
      chart_data[1][:data].push((counts[1] / total).round(2))
      chart_data[2][:data].push((counts[2] / total).round(2))
      chart_data[3][:data].push((counts[3] / total).round(2))
    end
    Rails.cache.write("gender_ratio", chart_data, expires_in: 12.hours)
    chart_data
  end

  def self.racer_days_gender_ratio(years)
    return Rails.cache.read("racer_days_gender_ratio") if Rails.cache.read("racer_days_gender_ratio").present?

    chart_data = [
      { name: "Not Specified", data: [] },
      { name: "Female", data: [] },
      { name: "Male", data: [] },
      { name: "NB", data: [] }
    ]
    years.each do |year|
      res = Result.joins(:event, :person).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).group("people.gender").count
      counts = [res[nil] || 0, res["F"] || 0, res["M"] || 0, res["NB"] || 0]
      total = counts.sum.to_f
      chart_data[0][:data].push((counts[0] / total).round(2))
      chart_data[1][:data].push((counts[1] / total).round(2))
      chart_data[2][:data].push((counts[2] / total).round(2))
      chart_data[3][:data].push((counts[3] / total).round(2))
    end
    Rails.cache.write("racer_days_gender_ratio", chart_data, expires_in: 12.hours)
    chart_data
  end

  def self.total_juniors(years)
    return Rails.cache.read("total_juniors") if Rails.cache.read("total_juniors").present?

    chart_data = [{ name: "Juniors", data: [] }]
    years.each do |year|
      res = Result.joins(:event).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).distinct
                  .count(:person_id)
      chart_data[0][:data].push(res)
    end
    Rails.cache.write("total_juniors", chart_data, expires_in: 12.hours)
    chart_data
  end
end
