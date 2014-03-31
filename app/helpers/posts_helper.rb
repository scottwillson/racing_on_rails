module PostsHelper
  def last_reply_at(post)
    date = post.last_reply_at || post.date
    if date.to_date == Time.zone.today
      date.to_s(:long_and_friendly_time)
    elsif date.year == Time.zone.today.year
      date.to_s(:short_month_date)
    else
      date.to_s(:short_month_date_year)
    end
  end
end
