class Home < ActiveRecord::Base
  belongs_to :photo
  
  def self.current
    Home.first || Home.create!
  end
end
