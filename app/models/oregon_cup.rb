# Year-long best rider competition for senior men and women
class OregonCup < Competition

  # 2006 races: 19, 80, 81, 259, 265, 381, 411
  # TODO Initialize OregonCup with "today" attribute
  # TODO Break ties according to rules on website
  after_save :create_standings
  validate :valid_dates
  
  has_many :events

  POINT_SCHEDULE = [
    0, 100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10
  ] unless defined?(POINT_SCHEDULE)
  
  # Calculate clashs with internal Rails method
  def OregonCup.recalculate(year = Date.today.year)
    OregonCup.transaction do
      date = Date.new(year)
      or_cup = OregonCup.find(:first, :conditions => ['date = ?', Date.new(year)])
      if or_cup
        or_cup.standings.clear
        or_cup.save!
      else
        or_cup = OregonCup.create(:date => date)
      end
      
      return if or_cup.events.empty?
      
      event_ids = or_cup.events.collect do |event|
        event.id
      end
      event_ids = event_ids.join(', ')
      for race in or_cup.standings.first.races
        scoring_results = Result.find_by_sql(
          %Q{SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
            LEFT OUTER JOIN races ON races.id = results.race_id 
              LEFT OUTER JOIN categories ON categories.id = races.category_id 
              LEFT OUTER JOIN standings ON races.standings_id = standings.id 
              LEFT OUTER JOIN events ON standings.event_id = events.id 
                WHERE races.category_id is not null 
                  and ((standings.bar_points > 0 and !(standings.name like '%Overall%'))
                       or (standings.bar_points = 0 and standings.name like '%Combined%'))
                  and place in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20) 
                  and categories.bar_category_id = #{race.bar_category.id} 
                  and events.id in (#{event_ids})
             order by racer_id
           }
        )
        
        previous_racer = nil
        or_cup_result = nil
        for scoring_result in scoring_results
          racer = scoring_result.racer
          if racer and racer.member?
            if racer != previous_racer
              or_cup_result = race.results.create(:racer => racer)
              previous_racer = racer
            end
            points = POINT_SCHEDULE[scoring_result.place.to_i]
            score = Score.new(:source_result => scoring_result, :competition_result => or_cup_result, :points => points)
            or_cup_result.scores << score
            or_cup_result.calculate_points
            or_cup_result.save!
          end
        end
      end

      for race in or_cup.standings.first.races
        race.results.sort! {|x,y| y.points <=> x.points }
        place = 1
        for result in race.results
          result.update_attribute(:place, place)
          place = place + 1
        end
      end
    end
    true
  end
  
  def initialize(attributes = nil)
    super
    self.name = 'Oregon Cup'
  end
  
  # If needed
  def create_standings
    if standings.empty?
      root_standings = standings.create(:event => self)

      category = Category.find_or_create_by_name_and_scheme("Senior Men", "OBRA")
      if category.bar_category.nil?
        # new
        category.position = 1
        category.bar_category = Category.find_bar("Senior Men")
        category.save!
      end
      root_standings.races.create(:category => category)

      category = Category.find_or_create_by_name_and_scheme("Senior Women", "OBRA")
      if category.bar_category.nil?
        # new
        category.position = 2
        category.bar_category = Category.find_bar("Senior Women")
        category.save!
      end
      root_standings.races.create(:category => category)
    end
  end
  
  def latest_event_with_standings
    for event in events.sort
      for standings in event.standings
        for race in standings.races
          if !race.results.empty?
            return event
          end
        end
      end
    end
    nil
  end
  
  def more_events?(today = Date.today)
    !self.next_event(today).nil?
  end
  
  # FIXME: Needs to sort by date?
  def next_event(today = Date.today)
    for event in events.sort
      if event.date > today
        return event
      end
    end
    nil
  end
end