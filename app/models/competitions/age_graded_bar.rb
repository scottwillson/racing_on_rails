module Competitions
  class AgeGradedBar < Competition

    CATEGORIES = []

    def points_for(scoring_result)
      scoring_result.points
    end

    def source_results(race)
      # Need date of birth range
      # Need category map from Masters Men to Masters Men 30-34, etc.
      # start_date_of_birth = last day of year prior to event year
      # end_date_of_birth = last day of event year
      Result.find(:all,
                  :include => [:race, {:racer => :team}, :team, {:race => [{:standings => :event}, :category]}],
                  :conditions => [%Q{events.type = 'OverallBar' 
                    and categories.id = #{race.category.parent(true).id}
                    and racers.date_of_birth between '#{race.dates_of_birth.begin}' and '#{race.dates_of_birth.end}'
                    and events.date >= '#{date.year}-01-01' 
                    and events.date <= '#{date.year}-12-31'}],
                  :order => 'racer_id'
      )
    end
    
    def create_standings
      root_standings = standings.create(:event => self)
      for category in create_categories
        root_standings.races.create!(:category => category)
      end
    end
    
    def create_categories
      if CATEGORIES.empty?
        CATEGORIES << Category.new(:name => 'Masters Men 30-34', :ages => 30..34, :parent => Category.new(:name => 'Masters Men'))
        CATEGORIES << Category.new(:name => 'Masters Men 35-39', :ages => 35..39, :parent => Category.new(:name => 'Masters Men'))
        for category in CATEGORIES
          if Category.exists?(:name => category.parent.name)
            category.parent = Category.find_by_name(category.parent.name)
          else
            category.parent.save!
          end
          
          unless Category.exists?(:name => category.name)
            category.save!
          end          
        end
      end
      CATEGORIES
    end

    def friendly_name
      'Age Graded BAR'
    end
  end
end