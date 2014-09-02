CelluloidBenchmark::Session.define do
  benchmark :mailing_list_posts
  page = get("http://obra.staging.rocketsurgeryllc.com/mailing_lists/1/posts")

  20.times do
    link = page.links_with(href: %r{/posts/\d+}).sample
    benchmark :post_show, 5
    link.click
  end
end
