class Region < ActiveRecord::Base
  include Concerns::Region::FriendlyParam

  before_save :set_friendly_param
  
  def set_friendly_param
    self.friendly_param = to_param
  end
end