# Who has done the most events? Just counts starts/appearences in results. Not pefect -- some events
# are probably over-counted.
# TODO Don't replace existing results
class Ironman < Competition
  def friendly_name
    'Ironman'
  end

  def Ironman.years
    years = []
    results = connection.select_all(
      "select distinct extract(year from date) as year from events where type = 'Ironman'"
    )
    results.each do |year|
      years << year.values.first.to_i
    end
    years.sort.reverse
  end
  
  def points_for(source_result)
    1
  end
  
  def break_ties?
    false
  end
  
  # Rebuild results
  # Override superclass for now. Superclass method duplicates calculations aldready done by Calculator.
  def calculate!
    races.each do |race|
      results = source_results_with_benchmark(race)
      calculated_results = Competitions::Calculator.calculate(results, dnf: true)
      create_competition_results_for(calculated_results, race)
    end
    
    after_calculate
    save!
  end

  # Results as array of hashes. Select fewest fields needed to calculate results.
  # Some competition rules applied here in the query and results excluded. It's a judgement call to apply them here
  # rather than in #calculate.
  def source_results(race)
    query = Result.
      select(["results.id as id", "person_id", "people.member_from", "people.member_to", "place", "results.event_id", "race_id", "events.date"]).
      joins(:race, :event, :person).
      where("place != 'DNS'").
      where("races.category_id is not null").
      where("events.type = 'SingleDayEvent' or events.type = 'Event' or events.type is null").
      where("events.ironman = true").
      where("results.year = ?", year)

    Result.connection.select_all query
  end
  
  # Similar to superclass's method, except this method only saves results to the database. Superclass applies rules 
  # and scoring, but . It also decorates the results with any display data (often denormalized)
  # like people's names, teams, and points.
  def create_competition_results_for(results, race)
    team_ids = team_ids_by_person_id_hash(results)
    
    results.each do |result|
      competition_result = Result.create!(
        :place              => result.place,
        :person_id          => result.person_id, 
        :team_id            => team_ids[result.person_id],
        :event              => self,
        :race               => race,
        :competition_result => true,
        :points             => result.points
      )
       
      result.scores.each do |score|
        create_score competition_result, score.source_result_id, score.points
      end
    end

    true
  end

  # Can move to superclass or to Result (competition results could know they need to lookup their team)
  def team_ids_by_person_id_hash(results)
    hash = Hash.new
    Person.select("id, team_id").where("id in (?)", results.map(&:person_id).uniq).map do |person|
      hash[person.id] = person.team_id
    end
    hash
  end

  # This is always the 'best' result
  def create_score(competition_result, source_result_id, points)
    Score.create!(
      :source_result_id => source_result_id, 
      :competition_result_id => competition_result.id, 
      :points => points
    )
  end
end
