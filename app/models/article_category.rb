require_dependency "acts_as_tree/validation"

# Homepage Article Category
class ArticleCategory < ActiveRecord::Base
  acts_as_tree order: "position"
  include ActsAsTree::Validation

  has_many :articles, -> { order("position desc") }
end
