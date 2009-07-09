class ArticleCategory < ActiveRecord::Base
  # TODO make sure no articles in category before delete

  has_many :articles , :order => "created_at desc"
  acts_as_tree :order=>"position"
end
