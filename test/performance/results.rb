CelluloidBenchmark::Session.define do
  benchmark :results_index, 1.2
  page = get("http://obra.staging.rocketsurgeryllc.com/results")

  20.times do
    link = page.links_with(class: "event").sample
    benchmark :results_event_show, 0.6
    link.click
  end
end
