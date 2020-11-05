# frozen_string_literal: true

require "acts_as_tree/validation"
require "categories"

# Senior Men, Pro/1/2, Novice Masters 45+
#
# Categories are just a simple hierarchy of names
#
# Categories are basically labels and there is no complex hierarchy. In other words, Senior Men Pro/1/2 and
# Pro/1/2 are two distinct categories. They are not combinations of Pro and Senior and Men and Cat 1
#
# +friendly_param+ is used for friendly links on BAR pages. Example: senior_men
class Category < ApplicationRecord
  acts_as_tree
  include ActsAsTree::Validation

  include Categories::Ability
  include Categories::Ages
  include Categories::Cleanup
  include Categories::Equipment
  # TODO: needed?
  include Comparable
  include Categories::FriendlyParam
  include Categories::Gender
  include Categories::NameNormalization
  include Categories::Matching
  include Categories::Weight
  include Export::Categories

  acts_as_list

  has_many :calculation_category_mappings,
           class_name: "Calculations::V3::CategoryMapping",
           dependent: :destroy,
           foreign_key: :category_id,
           inverse_of: :category

  has_many :calculation_categories, through: :calculation_category_mappings
  has_and_belongs_to_many :calculations, class_name: "Calculations::V3::Calculation" # rubocop:disable Rails/HasAndBelongsToMany
  has_many :results, dependent: :restrict_with_error
  has_many :races, dependent: :restrict_with_error

  before_validation :set_friendly_param

  validates :name, presence: true
  validates :friendly_param, presence: true

  before_save :set_abilities_from_name
  before_save :set_ages_from_name
  before_save :set_equipment_from_name
  before_save :set_gender_from_name
  before_save :set_weight_from_name

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
    joins(races: :results).where("results.year" => year).distinct
  }

  # All categories with no parent (except root 'association' category)
  def self.find_all_unknowns
    Category.includes(:children).where(parent_id: nil).where("name != ?", RacingAssociation.current.short_name)
  end

  # Update ability, age, equipment, etc. from names
  def self.update_all_from_names!
    ::Category.transaction do
      Category.all.find_each do |category|
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

    name.gsub("Senior", "Sr")
        .gsub("Masters", "Mst")
        .gsub("Junior", "Jr")
        .gsub("Category", "Cat")
        .gsub("Beginner", "Beg")
        .gsub("Expert", "Exp")
        .gsub("Clydesdale", "Clyd")
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
