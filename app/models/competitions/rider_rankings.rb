# WSBA rider rankings. Members get points for top-10 finishes in any event
class RiderRankings < Competition
  include Concerns::RiderRankings::Points

  def friendly_name
    'Rider Rankings'
  end

  def place_members_only?
    true
  end
  
  def create_races
    association_category = Category.find_or_create_by_name(RacingAssociation.current.short_name)
    for category_name in [
      'Junior Men A', 'Junior Men B', 'Junior Men C', 'Junior Men D',
      'Junior Women A', 'Junior Women B', 'Junior Women C', 'Junior Women D',
      'Men Cat 1-2', 'Men Cat 3', 'Men Cat 4-5', 
      'Master Men Cat 1-3', 'Master Men Cat 4-5', 
      'Masters 50+',
      'Masters Women A', 'Masters Women B', 
      'Women Cat 1-2', 'Women Cat 3', 'Women Cat 4']

      category = Category.find_or_create_by_name(category_name)
      unless category.parent
        category.parent = association_category
        category.save!
      end
      self.races.create(:category => category)
    end
  end

  # source_results must be in person-order
  def source_results(race)
    Result.all(
                :include => [:race, {:person => :team}, :team, {:race => [:event, :category]}],
                :conditions => [%Q{
                  members_only_place between 1 AND #{point_schedule.size - 1}
                    and results.person_id is not null
                    and events.type = 'SingleDayEvent' 
                    and events.sanctioned_by = "#{RacingAssociation.current.default_sanctioned_by}"
                    and categories.id in (#{category_ids_for(race).join(", ")})
                    and (races.bar_points > 0 or (races.bar_points is null and events.bar_points > 0))
                    and events.date between '#{date.beginning_of_year}' and '#{date.end_of_year}'
                }],
                :order => 'person_id'
    )
  end
  
  def member?(person, date)
    person && person.member?(date)
  end
end
