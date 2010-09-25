module ResultsHelper
  # Link to Person Result detail page
  def link_to_results(text, result)
    return text unless result.person_id

    if result.preliminary?
      html_options = ' class="preliminary"'
    end
    
    if result.competition_result?
      "<a href=\"/events/#{result.event_id}/people/#{result.person_id}/results\"#{html_options}>#{text}</a>"
    else
      "<a href=\"/people/#{result.person_id}/results\"#{html_options}>#{text}</a>"
    end
  end

  # Link to Person Result detail page
  def link_to_team_result(text, result)
    return text unless result.team_id

    if result.team_competition_result?
      "<a href=\"/events/#{result.event_id}/teams/#{result.team_id}/results\">#{text}</a>"
    else
      "<a href=\"/teams/#{result.team_id}/results\">#{text}</a>"
    end
  end
  
  def result_cell_class(column)
    case column
    when "laps", "number", "place", "points"
      " class=\"right\""
    end
  end
  
  def result_cell(result, column)
    case column
    when "first_name"
      link_to_results result.first_name, result
    when "last_name"
      link_to_results result.last_name, result
    when "name"
      link_to_results result.name, result
    when "team_name"
      link_to_team_result result.team_name, result
    else
      result.send column
    end
  end
end
