module PostsHelper
  def last_reply_at(post)
    date = post.last_reply_at || post.date
    if date.year == Time.zone.today.year
      date.to_s(:short_month_date)
    else
      date.to_s(:short_month_date_year)
    end
  end
end
