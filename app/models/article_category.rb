class ArticleCategory < ActiveRecord::Base
  # TODO make sure no articles in category before delete

  has_many :articles
  acts_as_tree :order=>"position"
end
