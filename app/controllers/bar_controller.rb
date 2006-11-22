# BAR = Best All-around Rider
class BarController < ApplicationController
  model :bar, :standings, :category
  session :off
  caches_page :show

  # Default to Overall BAR with links to disciplines
  def show
    @year = params['year'] || Date.today.year.to_s
    @discipline = params['discipline']
    @discipline = 'Overall' if @discipline.nil?
    @discipline = @discipline.titleize

    date = Date.new(@year.to_i, 1, 1)
    bar = Bar.find(:first, :conditions => ['date = ?', date])
    @standings = Standings.find(
      :first, 
      :conditions => ['event_id = ? and name = ?', bar.id, @discipline])

    unless @standings.nil?
      @standings.races.reject! do |race|
        race.results.empty?
      end
    end

    @all_disciplines = Discipline.find_all_bar.sort
  end
  
  # BAR category mappings
  def categories
    @year = params['year'] || Date.today.year.to_s
    date = Date.new(@year.to_i, 1, 1)
    @bar = Bar.find(:first, :conditions => ['date = ?', date])
    @excluded_categories = Category.find(:all, :conditions => ['scheme != ? and bar_category_id is null', 'BAR'])
  end
end
