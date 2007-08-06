class NewsItem < ActiveRecord::Base
  before_validation :defaults
  validates_presence_of :date, :text
  
  def defaults
    self.date = Date.today unless date
  end
end
