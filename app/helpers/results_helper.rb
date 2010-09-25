module ResultsHelper
  # Link to Person Result detail page
  def link_to_result(text, result)
    return text unless result.person_id

    if result.preliminary?
      html_options = { :class => :preliminary }
    else
      html_options = {}
    end
    
    if result.competition_result?
      link_to text, event_person_results_path(:event_id => result.event_id, :person_id => result.person_id), html_options
    else
      link_to text, person_results_path(:person_id => result.person_id), html_options
    end
  end

  # Link to Person Result detail page
  def link_to_team_result(text, result)
    return text unless result.team_id

    if result.team_competition_result?
      link_to text, event_team_results_path(:event_id => result.event_id, :team_id => result.team_id)
    else
      link_to text, team_results_path(:team_id => result.team_id)
    end
  end
end
