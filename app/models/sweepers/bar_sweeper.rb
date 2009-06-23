# A change to almost any model can effect the BAR (Race, Person, Category ...) so only sweep when BAR calculate!s 
class BarSweeper < ActionController::Caching::Sweeper
  observe Bar
  
  def after_save(event)
    if Rails.configuration.action_controller.perform_caching
      expire_page(:controller => "/bar", :action => "show")
      expire_page(:controller => "/bar", :action => "show", :year => event.date.year)
      for discipline in Discipline.find_all_bar
        expire_page(:controller => "/bar", :action => "show", :discipline => discipline, :year => event.date.year)
      end
    end
  end
end