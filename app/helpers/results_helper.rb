module ResultsHelper
  # Link to Person Result detail page
  def link_to_result(text, result)
    return text unless result.person

    if result.preliminary?
      html_options = { :class => :preliminary }
    else
      html_options = {}
    end
    
    if result.competition_result?
      link_to text, event_person_results_path(result.event, result.person), html_options
    else
      link_to text, person_results_path(result.person), html_options
    end
  end

  # Link to Person Result detail page
  def link_to_team_result(text, result)
    return text unless result.team

    if result.team_competition_result?
      link_to text, event_team_result_path(result.event, result.team, result.race)
    else
      link_to text, team_results_path(result.team)
    end
  end
end
