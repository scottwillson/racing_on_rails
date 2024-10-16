# frozen_string_literal: true

module Stats
  def self.cache_and_query(method, years)
    cache_key = "#{method} #{years}"
    if Rails.cache.read(cache_key).present?
      return Rails.cache.read(cache_key)
    end

    chart_data = send(method, years)
    Rails.cache.write(cache_key, chart_data, expires_in: 12.hours)
    chart_data
  end

  def self.racer_days_by_discipline(years)
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
    chart_data = [{ name: "Memberships", data: [] }]
    years.each do |year|
      res = LineItem.where(year: year, type: "LineItems::Membership").count
      chart_data[0][:data].push(res)
    end
    chart_data
  end

  def self.total_racer_days(years)
    chart_data = [{ name: "Total Racer Days", data: [] }]
    years.each do |year|
      res = Result.joins(:event).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).count
      chart_data[0][:data].push(res)
    end
    chart_data
  end

  def self.total_racers(years)
    chart_data = [{ name: "Racers", data: [] }]
    years.each do |year|
      res = Result.joins(:event).where(events: { year: year, type: "SingleDayEvent" })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).distinct
                  .count(:person_id)
      chart_data[0][:data].push(res)
    end
    chart_data
  end

  def self.racer_days_by_gender(years)
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
    chart_data
  end

  def self.racers_by_gender(years)
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
    chart_data
  end

  def self.gender_ratio(years)
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
      chart_data[0][:data].push((counts[0] / total).round(4))
      chart_data[1][:data].push((counts[1] / total).round(4))
      chart_data[2][:data].push((counts[2] / total).round(4))
      chart_data[3][:data].push((counts[3] / total).round(4))
    end
    chart_data
  end

  def self.racer_days_gender_ratio(years)
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
      chart_data[0][:data].push((counts[0] / total).round(4))
      chart_data[1][:data].push((counts[1] / total).round(4))
      chart_data[2][:data].push((counts[2] / total).round(4))
      chart_data[3][:data].push((counts[3] / total).round(4))
    end
    chart_data
  end

  def self.total_juniors(years)
    chart_data = [{ name: "Juniors", data: [] }]
    years.each do |year|
      beginning = Date.new(year, 1, 1).beginning_of_year
      res = Result.joins(:event, :person).where(events: { year: year, type: "SingleDayEvent" })
                  .where(people: { date_of_birth: beginning - 18.years..beginning })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil).distinct
                  .count(:person_id)
      chart_data[0][:data].push(res)
    end
    chart_data
  end

  def self.junior_racer_days(years)
    chart_data = [{ name: "Juniors", data: [] }]
    years.each do |year|
      res = Result.joins(:event, :person).where(events: { year: year, type: "SingleDayEvent" })
                  .where(people: { date_of_birth: beginning - 18.years..beginning })
                  .where(competition_result: false, team_competition_result: false)
                  .where.not(person_id: nil)
      chart_data[0][:data].push(res)
    end
    chart_data
  end
end
