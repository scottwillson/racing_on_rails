# Homepage Article Category
class ArticleCategory < ActiveRecord::Base
  has_many :articles, :order => "created_at desc"
  acts_as_tree :order => "position"
end
