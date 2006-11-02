module ScheduleHelper
  def links_to_years
    links = Builder::XmlMarkup.new(:indent => 4)
    links.div(:class => 'horizontal_links') {
      separator = ''
      for year in Event.find_all_years
        links.text!(separator)
        links.a(year, :href => url_for(:year => year))
        separator = ' | '
      end
    }
    links.to_s
  end

  def links_to_months(schedule)
    links = Builder::XmlMarkup.new(:indent => 4)
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
