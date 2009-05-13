class Article < ActiveRecord::Base
  belongs_to :article_category
  #I don't think I'm using any of the act_as_list functionality...
  acts_as_list :scope => :article_category
  #alptodo: make sure article category exists before saving
end
