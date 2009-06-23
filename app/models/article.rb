class Article < ActiveRecord::Base
  # TODO make sure article category exists before saving
  belongs_to :article_category
  acts_as_list :scope => :article_category
end
