# BAR = Best All-around Rider
# FIXME Add test for overall and make logic cleaner
module Competitions
  class BarController < ApplicationController
    def index
      @overall_bar = OverallBar.find_for_year
    end

    # Default to Overall BAR with links to disciplines
    def show
      discipline = Discipline[params['discipline']]
      if discipline.nil?
        flash.now[:warn] = "Could not find discipline \'#{params['discipline']}\'"
        return render(:show)
      end

      if @year < 2007 && discipline == Discipline[:age_graded]
        return redirect_to("http://#{RacingAssociation.current.static_host}/bar/#{@year}/overall_by_age.html")
      elsif @year < 2006 && @year >= 2001
        return redirect_to("http://#{RacingAssociation.current.static_host}/bar/#{@year}")
      end

      @overall_bar = OverallBar.find_for_year(@year)
      unless @overall_bar
        flash.now[:warn] = "Could not find Overall BAR for #{@year}"
        return render(:show)
      end

      category = @overall_bar.equivalent_category_for(params[:category], discipline)
      unless category
        flash.now[:warn] = "Could not find BAR category \'#{params['category']}\'"
        return render(:show)
      end
      return redirect_to(category: category.friendly_param, only_path: true) if category.friendly_param != params["category"]

      @race = @overall_bar.find_race(discipline, category)
      unless @race
        flash.now[:warn] = "Could not find results"
        return render(:show)
      end
    end
  end
end
