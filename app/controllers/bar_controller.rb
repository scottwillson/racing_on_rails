# BAR = Best All-around Rider
# FIXME Add test for overall and make logic cleaner
class BarController < ApplicationController
  caches_page :show
  
  def index
    @bar_categories = Discipline[:overall].bar_categories(true)
    @all_disciplines = Discipline.find_all_bar
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
      redirect_to("http://#{STATIC_HOST}/bar/#{@year}/overall_by_age.html")
      return    
    elsif @year < 2006
      redirect_to("http://#{STATIC_HOST}/bar/#{@year}")
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

      equivalent_category = @discipline.bar_categories.detect {|cat| cat.parent == @category} || @discipline.bar_categories.detect {|cat| cat == @category.parent} || @discipline.bar_categories.sort.first
      raise "Could not find equivalent category for #{@category.name} in #{@discipline.name}" unless equivalent_category
      redirect_to(:category => equivalent_category.friendly_param)
      return
    end
    raise "Could not find category '#{params['category']}'" unless @category
    
    if @discipline == Discipline[:overall]
        @race = Race.find(:first,
                          :include => :event,
                          :conditions => ['category_id = ? and events.date = ? and events.type = ?',
                                          @category.id, Date.new(@year), 'OverallBar'])

    elsif @discipline == Discipline[:team]
      @race = Race.find(:first,
                        :include => :event,
                        :conditions => ['events.date = ? and events.type = ?', 
                                        Date.new(@year), 'TeamBar'])
      @results = Result.find(:all, 
                             :include => [:team],
                             :conditions => ['race_id = ?', @race.id]
      ) if @race
      return

    elsif @discipline == Discipline[:age_graded]
      @race = Race.find(:first,
                        :include => :event,
                        :conditions => ['category_id = ? and events.date = ? and events.type = ?',
                                        @category.id, Date.new(@year), 'AgeGradedBar'])

    else
      @race = Race.find(:first,
                        :include => :event,
                        :conditions => ['category_id = ? and events.date = ? and events.type = ? and (events.discipline = ? or (events.discipline is null and events.discipline = ?))', 
                                        @category.id, Date.new(@year), 'Bar', @discipline.name, @discipline.name])
    end
    
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
