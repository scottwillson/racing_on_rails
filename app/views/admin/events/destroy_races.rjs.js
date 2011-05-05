@races.each do |race|
  page.visual_effect :puff, "race_#{race.id}_row", :duration => 0.2
end

if @combined_results
  page.visual_effect :puff, "event_#{@combined_results.id}_row", :duration => 0.2
end

page.visual_effect :fade, "destroy_races_progress", :duration => 0.1
page.hide "warn"
page.show "notice"
page["notice_span"].replace_html "Deleted races"
