# BAR = Best All-around Rider
# FIXME Add test for overall and make logic cleaner
class BarController < ApplicationController
  session :off
  caches_page :show

  # Default to Overall BAR with links to disciplines
  def show
    @year = params['year'] || Date.today.year.to_s
    @discipline = params['discipline']
    @discipline = 'Overall' if @discipline.nil?
    @discipline = @discipline.titleize

    date = Date.new(@year.to_i, 1, 1)
    if @discipline == 'Overall'
      if @year == '2006'
        bar = Bar.find(:first, :conditions => ['date = ?', date])
      else
        bar = OverallBar.find(:first, :conditions => ['date = ?', date])
      end
    else
      if @discipline == 'Team' and @year != '2006'
        bar = TeamBar.find(:first, :conditions => ['date = ?', date])
      elsif @discipline == 'Age Graded'
        bar = AgeGradedBar.find(:first, :conditions => ['date = ?', date])
      else
        bar = Bar.find(:first, :conditions => ['date = ?', date])
      end
    end
    
    # Huh?
    if bar
      if @discipline == 'Overall' || @discipline == 'Team'
        if @year == '2006'
          @standings = Standings.find(
            :first, 
            :conditions => ['event_id = ? and name = ?', bar.id, @discipline])
        else
          @standings = Standings.find(
            :first, 
            :conditions => ['event_id = ?', bar.id])
        end
      elsif @discipline == 'Age Graded'
        @standings = bar.standings(true).first
      else
        @standings = Standings.find(
          :first, 
          :conditions => ['event_id = ? and name = ?', bar.id, @discipline])
      end

      unless @standings.nil?
        @standings.races.reject! do |race|
          race.results.empty?
        end
      end
    end

    @all_disciplines = Discipline.find_all_bar.sort
  end
  
  # BAR category mappings
  def categories
    @year = params['year'] || Date.today.year.to_s
    date = Date.new(@year.to_i, 1, 1)
    @bar = Bar.find(:first, :conditions => ['date = ?', date])
    @excluded_categories = Category.find(:all, :conditions => ['parent_id is null'])
  end
end
