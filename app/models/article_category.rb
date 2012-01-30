# Homepage Article Category
class ArticleCategory < ActiveRecord::Base
  has_many :articles, :order => "position desc"
  acts_as_tree :order => "position"
end
