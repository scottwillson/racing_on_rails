module Admin::RacesHelper
  def link_to_events(race)
    html = ""

    race.event.ancestors.reverse.each do |e|
      html << link_to(truncate(e.name, :length => 40), edit_admin_event_path(e), :class => "obvious")
      html << ": "
    end

    html << link_to(truncate(race.event.name, :length => 40), edit_admin_event_path(race.event), :class => "obvious")
    html << ": "

    html
  end
end