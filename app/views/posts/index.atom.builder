atom_feed do |feed|
  feed.title @mailing_list.friendly_name
  feed.updated @posts.first.try(:date)

  @posts.each do |post|
    feed.entry(post, published: post.date) do |entry|
      entry.title post.subject
      entry.content post.body

      entry.author do |author|
        author.name post.from_email_obscured
      end
    end
  end
end
