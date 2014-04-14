# Homepage Article Category
class ArticleCategory < ActiveRecord::Base
  acts_as_tree order: "position"
  include ActsAsTree::Extensions
  include ActsAsTree::Validation

  has_many :articles, -> { order("position desc") }
end
