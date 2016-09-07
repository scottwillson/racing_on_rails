require "categories"

# Senior Men, Pro/1/2, Novice Masters 45+
#
# Categories are just a simple hierarchy of names
#
# Categories are basically labels and there is no complex hierarchy. In other words, Senior Men Pro/1/2 and
# Pro/1/2 are two distinct categories. They are not combinations of Pro and Senior and Men and Cat 1
#
# +friendly_param+ is used for friendly links on BAR pages. Example: senior_men
class Category < ActiveRecord::Base
  acts_as_tree
  include ActsAsTree::Validation

  include Categories::Ability
  include Categories::Ages
  include Categories::Cleanup
  include Categories::Equipment
  include Comparable
  include Categories::FriendlyParam
  include Categories::Gender
  include Categories::NameNormalization
  include Categories::Weight
  include Export::Categories

  acts_as_list

  has_many :results
  has_many :races

  before_validation :set_friendly_param

  validates_presence_of :name
  validates_presence_of :friendly_param

  scope :equivalent, lambda { |category|
    where(
      ability_begin: category.ability_begin,
      ability_end: category.ability_end,
      ages_begin: category.ages_begin,
      ages_end: category.ages_end,
      equipment: category.equipment,
      gender: category.gender,
      weight: category.weight
    )
  }

  scope :results_in_year, lambda { |year|
    joins(races: :results)
      .where("results.year" => year)
      .uniq
  }

  # All categories with no parent (except root 'association' category)
  def self.find_all_unknowns
   Category.includes(:children).where(parent_id: nil).where("name != ?", RacingAssociation.current.short_name)
  end

  # Update ability, age, equipment, etc. from names
  def self.update_all_from_names!
    ::Category.transaction do
      Category.all.each do |category|
        category.set_abilities_from_name
        category.set_ages_from_name!
        category.set_equipment_from_name
        category.set_gender_from_name
        category.set_weight_from_name

        category.save!
      end
    end
  end

  # Sr, Mst, Jr, Cat, Beg, Exp
  def self.short_name(name)
    return name if name.blank?
    name.gsub('Senior', 'Sr').gsub('Masters', 'Mst').gsub('Junior', 'Jr').gsub('Category', 'Cat').gsub('Beginner', 'Beg').gsub('Expert', 'Exp').gsub("Clydesdale", "Clyd")
  end

  def name=(value)
    self[:name] = Category.normalized_name(value)
  end

  def raw_name
    name
  end

  def raw_name=(value)
    self[:name] = value
  end

  # Sr, Mst, Jr, Cat, Beg, Exp
  def short_name
    Category.short_name name
  end

  def in?(other)
    return false unless other && other.is_a?(Category)

    abilities.in?(other.abilities) &&
    ages.in?(other.ages) &&
    equipment == other.equipment &&
    (other.gender == "M" || gender == "F") &&
    weight == other.weight
  end

  def equivalent?(other)
    return false unless other && other.is_a?(Category)

    abilities == other.abilities &&
    ages == other.ages &&
    equipment == other.equipment &&
    gender == other.gender &&
    weight == other.weight
  end

  # Find best matching competition race for category. Iterate through traits (weight, equipment, ages, gender, abilities) until there is a
  # single match (or none).
  def best_match_in(event)
    logger.debug "Category#best_match_in #{self.name} #{event.categories.map(&:name).join(', ')}"

    candidate_categories = event.categories

    equivalent_match = candidate_categories.detect { |category| equivalent?(category) }
    logger.debug "equivalent: #{equivalent_match&.name}"
    return equivalent_match if equivalent_match

    candidate_categories = candidate_categories.select { |category| weight == category.weight }
    logger.debug "weight: #{candidate_categories.map(&:name).join(', ')}"

    candidate_categories = candidate_categories.select { |category| equipment == category.equipment }
    logger.debug "equipment: #{candidate_categories.map(&:name).join(', ')}"

    candidate_categories = candidate_categories.select { |category| ages_begin.in?(category.ages) }
    logger.debug "ages: #{candidate_categories.map(&:name).join(', ')}"

    candidate_categories = candidate_categories.reject { |category| gender == "M" && category.gender == "F" }
    logger.debug "gender: #{candidate_categories.map(&:name).join(', ')}"

    candidate_categories = candidate_categories.select { |category| ability_begin.in?(category.abilities) }
    logger.debug "ability: #{candidate_categories.map(&:name).join(', ')}"
    return candidate_categories.first if candidate_categories.one?
    return nil if candidate_categories.empty?

    if junior?
      junior_categories = candidate_categories.select { |category| category.junior? }
      logger.debug "junior: #{junior_categories.map(&:name).join(', ')}"
      return junior_categories.first if junior_categories.one?
      if junior_categories.present?
        candidate_categories = junior_categories
      end
    end

    if masters?
      masters_categories = candidate_categories.select { |category| category.masters? }
      logger.debug "masters?: #{masters_categories.map(&:name).join(', ')}"
      return masters_categories.first if masters_categories.one?
      if masters_categories.present?
        candidate_categories = masters_categories
      end
    end

    # E.g., if Cat 3 matches Senior Men and Cat 3, use Cat 3
    # Could check size of range and use narrowest if there is a single one more narrow than the others
    candidate_categories = candidate_categories.reject { |category| category.all_abilities? }
    logger.debug "reject wildcards: #{candidate_categories.map(&:name).join(', ')}"
    return candidate_categories.first if candidate_categories.one?
    return nil if candidate_categories.empty?

    # "Highest" is lowest ability number
    highest_ability = candidate_categories.map(&:ability_begin).min
    if candidate_categories.one? { |category| category.ability_begin == highest_ability }
      highest_ability_category = candidate_categories.detect { |category| category.ability_begin == highest_ability }
      logger.debug "highest ability: #{highest_ability_category.name}"
      return highest_ability_category
    end

    candidate_categories = candidate_categories.reject { |category| gender == "F" && category.gender == "M" }
    logger.debug "exact gender: #{candidate_categories.map(&:name).join(', ')}"
    return candidate_categories.first if candidate_categories.one?
    return nil if candidate_categories.empty?

    logger.debug "no wild cards: #{candidate_categories.map(&:name).join(', ')}"
    return candidate_categories.first if candidate_categories.one?
    return nil if candidate_categories.empty?

    raise "Multiple matches #{candidate_categories.map(&:name)} for #{self.name} in #{event.categories.map(&:name).join(', ')}"
  end

  # Compare by position, then by name
  def <=>(other)
    return -1 if other.nil?
    return super unless other.is_a?(Category)
    return 0 if self[:id] && self[:id] == other[:id]
    diff = (position <=> other.position)
    if diff == 0
      name <=> other.name
    else
      diff
    end
  end

  def to_s
    "#<Category #{id} #{parent_id} #{position} #{name}>"
  end
end
