# frozen_string_literal: true

# Homepage content
class Article < ApplicationRecord
  belongs_to :article_category

  scope :recent_news, lambda { |weeks, category|
    where("created_at > :cutoff OR updated_at > :cutoff", cutoff: weeks)
      .where(article_category_id: category)
  }

  def <=>(other)
    return -1 unless other

    position <=> other.position
  end
end
