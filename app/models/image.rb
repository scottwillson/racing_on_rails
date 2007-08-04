class Image < ActiveRecord::Base
  validates_presence_of :name, :source
  validates_uniqueness_of :name
end
