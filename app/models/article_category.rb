class ArticleCategory < ActiveRecord::Base
#mbrahere: I added this model
  has_many :articles #, :order => :position
  acts_as_tree :order=>"position"
  #alptodo: make sure no articles in category before delete
end
