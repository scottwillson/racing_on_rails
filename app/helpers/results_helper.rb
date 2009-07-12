module ResultsHelper
  def link_to_result(text, result)
    return text unless result.person

    if result.preliminary?
      html_options = { :class => :preliminary }
    else
      html_options = {}
    end
    
    if result.competition_result?
      link_to(text, event_person_results_path(result.event, result.person), html_options)
    else
      link_to(text, person_results_path(result.person), html_options)
    end
  end

  def link_to_team_result(text, result)
    #mbrahere: the following prevents links thru to team results when displaying team bar results
    #I do not know why we do not link if not a person-specific result. A bug?
    #return text unless result.person
    return text unless result.team

    if result.competition_result?
      link_to(text, event_team_results_path(result.event, result.team))
    else
      link_to(text, team_results_path(result.team))
    end
  end
end
