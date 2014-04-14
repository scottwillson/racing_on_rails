# Homepage content
class Article < ActiveRecord::Base
  belongs_to :article_category
  acts_as_list scope: :article_category

  def <=>(other)
    return -1 unless other
    position <=> other.position
  end
end
