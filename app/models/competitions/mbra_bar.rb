# MBRA Best All-around Rider Competition.
# Calculates a BAR for each Discipline
# The BAR categories and disciplines are all configured in the databsase. Race categories need to have a bar_category_id to 
# show up in the BAR; disciplines must exist in the disciplines table and discipline_bar_categories.
#
# This class implements a number of MBRA-specific rules.
class MbraBar < Competition
  validate :valid_dates

  def self.calculate!(year = Time.zone.today.year)
    benchmark(name, :level => :info) {
      transaction do
        year = year.to_i if year.is_a?(String)
        date = Date.new(year, 1, 1)

        # Age Graded BAR and Overall BAR do their own calculations
        Discipline.find_all_bar.reject { |discipline|
          discipline == Discipline[:age_graded] || discipline == Discipline[:overall]
        }.each do |discipline|
          bar = MbraBar.where(:date => date, :discipline => discipline.name).first
          unless bar
            bar = MbraBar.create!(
              :name => "#{year} #{discipline.name} BAR",
              :date => date,
              :discipline => discipline.name
            )
          end
        end

        MbraBar.where(:date => date).each do |bar|
          bar.set_date
          bar.destroy_races
          bar.create_races
          bar.calculate_threshold_number_of_races
          bar.calculate!
          bar.after_create_all_results
        end
      end
    }
    # Don't return the entire populated instance!
    true
  end
  
  def self.find_by_year_and_discipline(year, discipline_name)
    MbraBar.year(year).where(:discipline => discipline_name).first
  end
  
  def calculate_threshold_number_of_races
    # 70% of the races (rounded to the nearest whole number) count in the BAR standings.
    @threshold_number_of_races = (Event.find_all_bar_for_discipline(self.discipline, self.date.year).size * 0.7).round.to_i
  end

  def point_schedule
    @point_schedule = @point_schedule || []
  end

  # Riders obtain points inversely proportional to the starting field size, 
  # plus bonuses for first, second and third place (6, 3, and 1 points respectively).
  # DNF: 1/2  point
  def calculate_point_schedule(field_size)
    @point_schedule = [0]
    field_size.downto(1) { |i| @point_schedule << i }
    @point_schedule[1] += 6 if @point_schedule.length > 1
    @point_schedule[2] += 3 if @point_schedule.length > 2
    @point_schedule[3] += 1 if @point_schedule.length > 3
  end

  # Source result = counts towards the BAR "race" and BAR results
  # Example: Piece of Cake RR, 6th, Jon Knowlson
  #
  # bar_result, bar_race = BAR itself and placing in the BAR
  # Example: Senior Men BAR, 130th, Jon Knowlson, 45 points
  #
  # BAR results add scoring results as scores
  # Example: 
  # Senior Men BAR, 130th, Jon Knowlson, 18 points
  #  - Piece of Cake RR, 6th, Jon Knowlson 10 points
  #  - Silverton RR, 8th, Jon Knowlson 8 points
  def source_results(race)
    category_ids = category_ids_for(race).join(", ")

    Result.
    includes(:race, {:person => :team}, :team, {:race => [{:event => { :parent => :parent }}, :category]}).
      where(%Q{
        (events.type in ('Event', 'SingleDayEvent', 'MultiDayEvent') or events.type is NULL)
        and bar = true
        and categories.id in (#{category_ids})
        and (events.discipline = '#{race.discipline}'
          or (events.discipline is null and parents_events.discipline = '#{race.discipline}')
          or (events.discipline is null and parents_events.discipline is null and parents_events_2.discipline = '#{race.discipline}'))
        and (races.bar_points > 0
          or (races.bar_points is null and events.bar_points > 0)
          or (races.bar_points is null and events.bar_points is null and parents_events.bar_points > 0)
          or (races.bar_points is null and events.bar_points is null and parents_events.bar_points is null and parents_events_2.bar_points > 0))
        and events.date between '#{date.year}-01-01' and '#{date.year}-12-31'
    }).
    order(:person_id)
  end

  # Apply points from point_schedule
  def points_for(source_result, team_size = nil)
    calculate_point_schedule(source_result.race.field_size)
    points = 0
    MbraBar.benchmark('points_for', :level => "debug") {
      if source_result.place.strip.downcase == "dnf"
        points = 0.5
      else
        # if multiple riders got the same place (must be a TTT or tandem team or... ?), then they split the points...
        # this screws up the scoring of match sprints where riders eliminated in qualifying heats all earn the same place
        points = point_schedule[source_result.place.to_i] * source_result.race.bar_points #/ team_size.to_f
      end
    }
    points
  end
  
  def after_create_competition_results_for(race)
    # 70% of the races (rounded to the nearest whole number) count in the
    # individual series standings. Riders who compete in more than 70% of the
    # races will throw out their weakest results.
    race.results.each do |result|
      # Don't bother sorting scores unless we need to drop some
      if result.scores.size > @threshold_number_of_races
        result.scores.sort! { |x, y| y.points <=> x.points }
        for lowest_score in result.scores[@threshold_number_of_races..(result.scores.size - 1)]
          result.scores.destroy(lowest_score)
        end
        # Rails destroys Score in database, but doesn't update the current association
        result.scores(true)
      end
    end
  end

  def after_create_all_results
    # Riders upgrading during the season will take 1/2 of their points (up to 30 points max)
    # with them to the higher category. The upgrading rider's accumulated points are allowed to stand at the
    # lower category.
    # After computing BAR results, look for Cat n BAR results for anyone in the Cat n - 1 BAR and add in half their Cat n points.
    [
      ["cat_up" => "Cat 1/2 Men", "cat_down" => "Cat 3 Men"],
      ["cat_up" => "Cat 3 Men", "cat_down" => "Cat 4 Men"],
      ["cat_up" => "Cat 4 Men", "cat_down" => "Cat 5 Men"],
      ["cat_up" => "Cat 1/2/3 Women", "cat_down" => "Cat 4 Women"]
    ].each do |category_pair|
      cat_up_race = self.races.detect { |r| r.category.name == category_pair[0]["cat_up"] }
      cat_down_race = self.races.detect { |r| r.category.name == category_pair[0]["cat_down"] }
      cat_up_race.results.each do |up_result|
        take_with_result = cat_down_race.results.detect { |down_result| down_result.person == up_result.person }
        unless take_with_result.blank?
          upgrade_points = (take_with_result.points/2).to_i
          upgrade_points = 30 if upgrade_points > 30
          up_result.points += upgrade_points
          upgrade_note = "Point total includes #{upgrade_points} upgrade points."
          if up_result.notes.blank?
            up_result.notes = upgrade_note
          else  
            up_result.notes += " #{upgrade_note}"
          end
          up_result.save!
        end
      end unless (cat_up_race.blank? || cat_down_race.blank?)

    end
  end

  def create_races
    Discipline[discipline].bar_categories.each do |category|
      races.create!(:category => category)
      logger.debug("#{self.class.name} created BAR race in discipline #{discipline} for category '#{category}'") if logger.debug?
    end
  end

  def members_only?
    false
  end

  def friendly_name
    'MBRA BAR'
  end

  def to_s
    "#<#{self.class.name} #{id} #{discipline} #{name} #{date}>"
  end

end
