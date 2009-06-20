module ResultsHelper
  def link_to_result(text, result)
    return text unless result.person

    if result.preliminary?
      html_options = { :class => :preliminary }
    else
      html_options = {}
    end
    
    if result.competition_result?
      link_to(text, 
        { :controller => 'results',
          :action => 'competition',
          :competition_id => result.event.to_param,
          :person_id => result.person_id },
        html_options)
    else
      link_to(text, person_results_path(result.person), html_options)
    end
  end
end