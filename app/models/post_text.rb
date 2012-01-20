class PostText < ActiveRecord::Base
  belongs_to :post
  validates_presence_of :post
end
