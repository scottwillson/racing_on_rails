require 'racingonrails/app/models/single_day_event'

class SingleDayEvent < Event
  def SingleDayEvent.find_all_by_year(year)
    [SingleDayEvent.create(:name => 'Custom Finder Event')]
  end
  
  def name
    "<i>#{self[:name]}</i>"
  end
  
end