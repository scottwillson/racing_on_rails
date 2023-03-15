# frozen_string_literal: true

class WeeklySeries < Series
  # TODO: Is this duplicated from Ruby core and standard lib?
  DAYS_OF_WEEK = %w[Su M Tu W Th F Sa].freeze unless defined?(DAYS_OF_WEEK)
  LONG_DAYS_OF_WEEK = %w[Sun Mon Tue Wed Thu Fri Sat].freeze unless defined?(LONG_DAYS_OF_WEEK)

  # 0-based. Doesn't handle multiple days of the week. Method names here are confusing.
  def day_of_week
    if children.empty?
      date.wday
    else
      children.min_by(&:date).date.wday
    end
  end

  def earliest_day_of_week(date_range, reload = false)
    days_of_week(date_range, reload).min || -1
  end

  # Formatted list. Examples:
  # * Tuesday PIR: Tu
  # * Track classes: M, W, F
  def days_of_week_as_string(date_range, reload = false)
    case days_of_week(date_range, reload).size
    when 0
      ""
    when 1
      LONG_DAYS_OF_WEEK[days_of_week(false).first]
    else
      days_of_week(false).collect { |day| DAYS_OF_WEEK[day] }.join("/")
    end
  end

  # Array of Integers. Sunday is 0. Ordered. Duplicates removed.
  # Caches result, even if date_range changes, and doesn't notice database changes.
  def days_of_week(date_range, reload = false)
    if reload || @days_of_week.nil?
      @days_of_week = WeeklySeries.connection.select_values(%{
          select distinct (DAYOFWEEK(date) - 1) as day_of_week
          from events
          where parent_id=#{id} and date between '#{date_range.begin.to_s(:db)}' and '#{date_range.end.to_s(:db)}'
          order by day_of_week})
      @days_of_week.map!(&:to_i)
    end
    @days_of_week
  end

  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{date} #{children.size}>"
  end
end
