# frozen_string_literal: true

module Admin::RacesHelper
  # Build links like Cascade Classic: Mt. Bachelor Stage: Senior Men
  def link_to_events(race)
    html = +""

    race.event.ancestors.reverse_each do |e|
      html << link_to(truncate(e.name, length: 40), edit_admin_event_path(e), class: "obvious")
      html << ": "
    end

    html << link_to(truncate(race.event.name, length: 40), edit_admin_event_path(race.event), class: "obvious")
    html << ": "

    html.html_safe
  end

  # BAR category or Rider Rankings category
  def competition_category_name(race)
    if race&.category
      if race.category.parent
        return race.category.parent.name
      else
        return race.category.name
      end
    end
    ""
  end
end
