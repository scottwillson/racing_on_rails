class Name < ActiveRecord::Base
  def date=(value)
    self.year = value.year
  end
end
