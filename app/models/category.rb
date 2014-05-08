require_dependency "acts_as_tree/validation"

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
  include ActsAsTree::Validation

  include Categories::Ages
  include Categories::Cleanup
  include Comparable
  include Categories::FriendlyParam
  include Export::Categories

  acts_as_list

  has_many :results
  has_many :races

  before_validation :set_friendly_param

  validates_presence_of :name
  validates_presence_of :friendly_param

  NONE = Category.new(name: "", id: nil)
  RACING_ASSOCIATIONS = %{ ABA ATRA CBRA MBRA NABRA OBRA WSBA }

  # All categories with no parent (except root 'association' category)
  def self.find_all_unknowns
   Category.includes(:children).where(parent_id: nil).where("name != ?", RacingAssociation.current.short_name)
  end

  # Sr, Mst, Jr, Cat, Beg, Exp
  def self.short_name(name)
    return name if name.blank?
    name.gsub('Senior', 'Sr').gsub('Masters', 'Mst').gsub('Junior', 'Jr').gsub('Category', 'Cat').gsub('Beginner', 'Beg').gsub('Expert', 'Exp').gsub("Clydesdale", "Clyd")
  end

  def self.strip_whitespace(name)
    if name
      name = name.strip
      name = name.gsub(/\s+/, " ")
      # E.g., 30 - 39
      name = name.gsub(/(\d+)\s+-\s+(\d+)/, "\\1-\\2")
      # 1 / 2 => 1/2
      name = name.gsub(/\s+\/\s+/, "/")
    end
    name
  end

  def self.cleanup_case(name)
    if name
      name = name.split.map do |token|
        # Calling RacingAssociation.current triggers an infinite loop
        if token[/of/i]
          "of"
        elsif token[/\Ai+\z/i] || token[/\A\d[a-z]/i]
          token.upcase
        elsif token.in?(RACING_ASSOCIATIONS) || token.in?(%w{ MTB SS TT TTT }) || token[/\A[A-Z][a-z]/]
          token
        else
          token.downcase.gsub(/\A[a-z]/) { $&.upcase }.gsub(/[[:punct:]][a-z]/) { $&.upcase }
        end
      end.join(" ")
    end
    name
  end

  def self.expand_abbreviations(name)
    if name
      name = name.split.map do |token|
        if token[/\Acat\.?\z/i]
          "Category"
        elsif token[/\Asr\.?\z/i] || token[/\Aseniors\z/i] || token[/\Asenoir\z/i]
          "Senior"
        elsif token[/\Ajr\.?\z/i] || token[/\Ajuniors\z/i]
          "Junior"
        elsif token[/\Amaster\z/i] || token[/\Amas\z/i] || token[/\Amstr?\z/i]
          "Masters"
        elsif token[/\Aveteran'?s\z/i] || token[/\Aveteren\z/i] || token[/\Avet\.?\z/i]
          "Veteran"
        elsif token[/\Aclydesdales\z/i]
          "Clydesdale"
        elsif token[/\Amen'?s\z/i]
          "Men"
        elsif token[/\Awomen'?s\z/i] || token[/\Awoman'?s\z/i]
          "Women"
        elsif token[/\Awmn?\.?\z/i] || token[/\Awom\.?\z/i] || token[/\Aw\z/i] || token[/\Awmen?\.?\z/i]
          "Women"
        elsif token[/\Abeg?\.?\z/i] || token[/\Abegin?\.?\z/i] || token[/\Abeginners\z/i]
          "Beginner"
        elsif token[/\Aexp\.?\z/i] || token[/\Aexpt\.?\z/i]
          "Expert"
        elsif token[/\Asprt\.?\z/i]
          "Sport"
        elsif token[/\Asinglespeeds?\z/i] || token[/\Ass\z/i]
          "Singlespeed"
        elsif token[/\Atand?\z/i] || token[/\Atandems\z/i]
          "Tandem"
        elsif token == "&"
          "and"
        else
          token
        end
      end.join(" ")

      name = name.gsub(/single speeds?/i, "Singlespeed")
      name = name.gsub(/sgl spd/i, "Singlespeed")
      name = name.gsub(/sgl speed/i, "Singlespeed")

      name = name.gsub(/(\d+) ?and ?under/i, 'U\1')
      name = name.gsub(/(\d+) ?& ?under/i, 'U\1')

      name = name.gsub(/(\d+) ?m/i, '\1m')
      name = name.gsub(/(\d+) ?k/i, '\1K')

      name = name.gsub(/\d+\) ?/, "")
    end
    name
  end

  def self.normalized_name(name)
    _name = strip_whitespace(name)
    _name = cleanup_case(_name)
    expand_abbreviations _name
  end

  def self.find_or_create_by_normalized_name(name)
    Category.find_or_create_by name: normalized_name(name)
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
