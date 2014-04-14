# See Bar class.
class OverallBar < Competition
  # TODO When migrated to Competition::Calculator, need to ensure tied discipline BAR results are not counted as "team" results
  include Concerns::OverallBar::Categories
  include Concerns::OverallBar::Points
  include Concerns::OverallBar::Races
  include Concerns::OverallBar::Results

  def create_children
    Discipline.find_all_bar.
    reject { |discipline| [Discipline[:age_graded], Discipline[:overall], Discipline[:team]].include?(discipline) }.
    each do |discipline|
      bar = Bar.year(year).where(discipline: discipline.name).first
      unless bar
        bar = Bar.create!(
          parent: self,
          name: "#{year} #{discipline.name} BAR",
          date: date,
          discipline: discipline.name
        )
      end
    end
  end

  def friendly_name
    'Overall BAR'
  end

  def default_discipline
    "Overall"
  end
end
