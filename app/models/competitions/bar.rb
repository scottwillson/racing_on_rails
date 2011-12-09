# Best All-around Rider Competition. Assigns points for each top-15 placing in major Disciplines: road, track, etc.
# Calculates a BAR for each Discipline, and an Overall BAR that combines all the discipline BARs.
# Also calculates a team BAR.
# Recalculating the BAR at years-end can take nearly 30 minutes even on a fast server. Recalculation must be manually triggered.
# This class implements a number of OBRA-specific rules and should be generalized and simplified.
# The BAR categories and disciplines are all configured in the database. Race categories need to have a bar_category_id to 
# show up in the BAR; disciplines must exist in the disciplines table and discipline_bar_categories.
class Bar < Competition
  include Concerns::Bar::Categories
  include Concerns::Bar::Discipline
  include Concerns::Bar::Points
  
  def Bar.calculate!(year = Time.zone.today.year)
    benchmark(name, :level => :info) {
      transaction do
        year = year.to_i if year.is_a?(String)
        date = Date.new(year, 1, 1)
        
        overall_bar = OverallBar.find_or_create_for_year(year)

        # Age Graded BAR, Team BAR and Overall BAR do their own calculations
        ::Discipline.find_all_bar.reject { |discipline|
          [ ::Discipline[:age_graded], ::Discipline[:overall], ::Discipline[:team] ].include?(discipline)
        }.each do |discipline|
          bar = Bar.first(:conditions => { :date => date, :discipline => discipline.name })
          unless bar
            bar = Bar.create!(
              :parent => overall_bar,
              :name => "#{year} #{discipline.name} BAR",
              :date => date,
              :discipline => discipline.name
            )
          end
        end

        Bar.all( :conditions => { :date => date }).each do |bar|
          bar.destroy_races
          bar.create_races
          # Could bulk load all Event and Races at this point, but hardly seems to matter
          bar.calculate!
        end
      end
    }
    # Don't return the entire populated instance!
    true
  end
  
  def Bar.find_by_year_and_discipline(year, discipline_name)
    Bar.first(:conditions => { :date => Date.new(year), :discipline => discipline_name })
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
    race_disciplines = disciplines_for(race).map { |d| "'#{d}'" }.join(", ")
    category_ids = category_ids_for(race).join(", ")

    Result.all(
      :include => [:race, {:person => :team}, :team, {:race => [{:event => { :parent => :parent }}, :category]}],
      :conditions => [%Q{
        place between 1 AND #{point_schedule.size - 1}
          and (events.type in ('Event', 'SingleDayEvent', 'MultiDayEvent', 'Series', 'WeeklySeries', 'TaborOverall') or events.type is NULL)
          and bar = true
          and events.sanctioned_by = "#{RacingAssociation.current.default_sanctioned_by}"
          and categories.id in (#{category_ids})
          and (events.discipline in (#{race_disciplines})
            or (events.discipline is null and parents_events.discipline in (#{race_disciplines}))
            or (events.discipline is null and parents_events.discipline is null and parents_events_2.discipline in (#{race_disciplines})))
          and (races.bar_points > 0
            or (races.bar_points is null and events.bar_points > 0)
            or (races.bar_points is null and events.bar_points is null and parents_events.bar_points > 0)
            or (races.bar_points is null and events.bar_points is null and parents_events.bar_points is null and parents_events_2.bar_points > 0))
          and events.date between '#{date.year}-01-01' and '#{date.year}-12-31'
      }],
      :order => 'person_id'
      )
  end

  def create_races
    ::Discipline[discipline].bar_categories.each do |category|
      races.create!(:category => category)
    end
  end

  def friendly_name
    'BAR'
  end

  def to_s
    "#<#{self.class.name} #{id} #{discipline} #{name} #{date}>"
  end
end
