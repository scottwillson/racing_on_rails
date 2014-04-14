# Senior Men, Pro 1/2, Novice Masters 45+
#
# Categories are just a simple hierarchy of names
#
# Categories are basically labels and there is no complex hierarchy. In other words, Senior Men Pro 1/2 and
# Pro 1/2 are two distinct categories. They are not combinations of Pro and Senior and Men and Cat 1
#
# +friendly_param+ is used for friendly links on BAR pages. Example: senior_men
class Category < ActiveRecord::Base
  acts_as_tree
  include Concerns::TreeExtensions
  include Concerns::TreeValidation

  include Ages
  include Comparable
  include Concerns::Category::FriendlyParam
  include Export::Categories

  acts_as_list

  has_many :results
  has_many :races

  before_validation :set_friendly_param

  validates_presence_of :name
  validates_presence_of :friendly_param

  NONE = Category.new(name: "", id: nil)

  # All categories with no parent (except root 'association' category)
  def self.find_all_unknowns
   Category.includes(:children).where(parent_id: nil).where("name != ?", RacingAssociation.current.short_name)
  end

  # Sr, Mst, Jr, Cat, Beg, Exp
  def self.short_name(name)
    return name if name.blank?
    name.gsub('Senior', 'Sr').gsub('Masters', 'Mst').gsub('Junior', 'Jr').gsub('Category', 'Cat').gsub('Beginner', 'Beg').gsub('Expert', 'Exp').gsub("Clydesdale", "Clyd")
  end

  # Sr, Mst, Jr, Cat, Beg, Exp
  def short_name
    Category.short_name name
  end

  # Compare by position, then by name
  def <=>(other)
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
