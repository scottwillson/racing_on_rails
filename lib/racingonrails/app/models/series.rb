class Series < MultiDayEvent

  def Series.find_all_by_year(year)
    logger.debug("Series.find_all_by_year(year)")
    # Load WeeklySeries so Rails knows it exists!
    # TODO Still needed?
    #WeeklySeries
    start_of_year = Date.new(year, 1, 1)
    end_of_year = Date.new(year, 12, 31)
    return Series.find(
      :all,
      :conditions => ["date >= ? and date <= ?", start_of_year, end_of_year],
      :order => "date"
    )
  end

  def friendly_class_name
    "Series"
  end

end