module ResultsHelper
  def link_to_result(text, result)
    return text unless result.racer

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
          :racer_id => result.racer_id },
        html_options)
    else
      link_to(text, "/results/racer/#{result.racer.id}", html_options)
    end
  end
end