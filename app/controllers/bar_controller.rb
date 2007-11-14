# BAR = Best All-around Rider
# FIXME Add test for overall and make logic cleaner
class BarController < ApplicationController
  session :off
  caches_page :show
  
  def index
    @bar_categories = Discipline[:overall].bar_categories(true)
    @all_disciplines = Discipline.find_all_bar.sort
    @year = Date.today.year
  end

  # Default to Overall BAR with links to disciplines
  def show
    @year = params['year'].to_i
    if @year < 1990 or @year > Date.today.year
      flash[:notice] = "\'#{params['year']}\' is not a valid year"
      return render(:action => 'not_found')
    end

    @discipline = Discipline[params['discipline']]
    if @discipline.nil?
      flash[:notice] = "Discipline \'#{params['discipline']}\' does not exist"
      return render(:action => 'not_found')
    end
    
    if @year < 2007 && @discipline == Discipline[:age_graded]
      redirect_to("/bar/#{@year}/overall_by_age.html")
      return
    end
    
    @all_disciplines = Discipline.find_all_bar.sort

    @category = @discipline.bar_categories(true).detect {|cat| cat.friendly_param == params['category']}
    if @category.nil?
      for discipline in @all_disciplines
        @category = discipline.bar_categories(true).detect {|cat| cat.friendly_param == params['category']}
        break if @category
      end

      if @category.nil?
        flash[:notice] = "Category \'#{params['category']}\' does not exist"
        return render(:action => 'not_found')
      end

      equivalent_category = @discipline.bar_categories.detect {|cat| cat.parent == @category} || @discipline.bar_categories.detect {|cat| cat == @category.parent} || @discipline.bar_categories.first
      raise "Could not find equivalent category for #{@category.name} in #{@discipline.name}" unless equivalent_category
      redirect_to(:category => equivalent_category.friendly_param)
      return
    end
    raise "Could not find category '#{params['category']}'" unless @category
    
    if @discipline == Discipline[:overall]
      bar_type = 'OverallBar'
    elsif @discipline == Discipline[:team]
      bar_type = 'TeamBar'
    elsif @discipline == Discipline[:age_graded]
      bar_type = 'AgeGradedBar'
    else
      bar_type = 'Bar'
    end
    
    @race = Race.find(:first,
                      :include => [{:standings => :event}],
                      :conditions => ['category_id = ? and events.date = ? and events.type = ? and standings.discipline = ?', 
                                      @category.id, Date.new(@year), bar_type, @discipline.name])
    
    # Optimization
    @results = Result.find(:all, 
                           :include => [:racer, :team],
                           :conditions => ['race_id = ?', @race.id]
    ) if @race
  end
  
  # BAR category mappings
  def categories
    @year = params['year'] || Date.today.year.to_s
    date = Date.new(@year.to_i, 1, 1)
    @bar = Bar.find(:first, :conditions => ['date = ?', date])
    @excluded_categories = Category.find(:all, :conditions => ['parent_id is null'])
  end
end
