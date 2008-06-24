module ScheduleHelper
  def links_to_years
    years = Event.find_all_years
    return unless years.size > 1
    
    links = Builder::XmlMarkup.new(:indent => 2)
    links.div(:class => 'horizontal_links') {
      separator = ''
      years.each do |year|
        links.text!(separator)
        links.a(year, :href => url_for(:year => year))
        separator = ' | '
      end
    }
    links.to_s
  end

  def links_to_months(schedule)
    links = Builder::XmlMarkup.new(:indent => 2)
    links.div(:class => 'horizontal_links') {
      separator = ''
      for month in @schedule.months
        links.text!(separator)
        links.a(month.name, :href => "##{month.name}")
        separator = ' | '
      end
    }
    links.to_s
  end
end
