require "result_column"

module ResultsHelper
  # Link to Person Result detail page
  def link_to_results(text, result)
    return text unless result.person_id

    if result.preliminary?
      html_options = ' class="preliminary"'
    end
    
    if result.competition_result?
      "<a href=\"/events/#{result.event_id}/people/#{result.person_id}/results##{result.race_id}\"#{html_options}>#{text}</a>".html_safe
    else
      "<a href=\"/people/#{result.person_id}/#{result.year}\"#{html_options}>#{text}</a>".html_safe
    end
  end

  # Link to Person Result detail page
  def link_to_team_results(text, result)
    return text unless result.team_id

    if result.team_competition_result?
      "<a href=\"/events/#{result.event_id}/teams/#{result.team_id}/results/#{result.race_id}\">#{text}</a>".html_safe
    else
      "<a href=\"/teams/#{result.team_id}/#{result.year}\">#{text}</a>".html_safe
    end
  end
  
  def result_header(column)
    ::ResultColumn[column].description
  end

  def result_cell_class(column)
    if ::ResultColumn[column].alignment == :right
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
      if RacingAssociation.current.unregistered_teams_in_results? || result.team.try(:member?) || result.year < RacingAssociation.current.year
        link_to_team_results result.team_name, result
      end
    else
      result.send ::ResultColumn[column].display_method
    end
  end
end
