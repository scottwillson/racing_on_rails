# Homepage Article Category
class ArticleCategory < ActiveRecord::Base
  acts_as_tree order: "position"
  include Concerns::TreeExtensions
  include Concerns::TreeValidation

  has_many :articles, -> { order("position desc") }
end
