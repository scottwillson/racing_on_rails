CelluloidBenchmark::Session.define do
  benchmark :results_index
  page = get("http://obra.staging.rocketsurgeryllc.com/results")

  20.times do
    link = page.links_with(class: "event").sample
    benchmark :results_event_show, 5
    link.click
  end
end
