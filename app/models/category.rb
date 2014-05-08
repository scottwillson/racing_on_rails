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
      name = name.gsub(/(\d+)\s?-\s?(\d+)/, '\1-\2')

      # 1 / 2 => 1/2
      name = name.gsub(/\s?\/\s?/, "/")

      # 6- race
      name = name.gsub(/\s+-\s?/, " - ")
      name = name.gsub(/\s?-\s+/, " - ")

      # 40 + => 40+
      name = name.gsub(/(\d+)\s+\+/, '\1+')

      # U 14, U-14
      name = name.gsub(/U[ -](\d\d)/, 'U\1')

      # Men30+
      name = name.gsub(/(masters|master|men|women)(\d\d\+)/i, '\1 \2')
    end
    name
  end

  def self.split_camelcase(name)
    if name && !(name.downcase == name || name.upcase == name)
      name = name.gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1 \2')
      name = name.gsub(/([a-z\d])([A-Z])/,'\1 \2')
    end
    name
  end

  def self.cleanup_punctuation(name)
    if name
      # trailing punctuation
      name = name.gsub(/[\/:.,"]\z/, "")

      # Men (Juniors)
      name = name.gsub(/\((masters|master|juniors|junior|men|women)\)/i, '\1')

      # 1 2, 2 3, 3.4.5, 2-3-4 to 1/2/3
      5.downto(2).each do |length|
        [ "P", 1, 2, 3, 4, 5 ].each_cons(length) do |cats|
          [ " ", ".", "-" ].each do |delimiter|
            name = name.gsub(%r{( ?)#{cats.join(delimiter)}( ?)},
            "\\1#{cats.join("/")}\\2")
          end
        end
      end

      name = name.gsub(%r{//+}, "/")

      name = name.gsub(%r{\+ -( ?)}, "+ ")

      name = name.gsub(/six[ -]?day/i, "Six-day")

      name = name.gsub(/(\d+) day/i, '\1-Day')
      name = name.gsub(/(\d+) hour/i, '\1-Hour')
      name = name.gsub(/(\d+) mile/i, '\1-Mile')

      name = name.gsub(/(\d+) man/i, '\1-Man')
      name = name.gsub(/(\d+) person/i, '\1-Person')

      name = name.gsub(/(one|two|three|four|five|six)[ -]man/i, '\1-Man')
      name = name.gsub(/(one|two|three|four|five|six)[ -]person/i, '\1-Person')

      unless name[/laps/i]
        name = name.gsub(/(\d+) lap/i, '\1-Lap')
      end
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
        elsif token[/\Ac{1,2}x\z/i]
          token.upcase
        elsif token[/\Att-?\w*/i] || token[/\A-?tt\w*/i]
          token.gsub(/tt/i, "TT")
        elsif token[/\Attt-?\w*/i] || token[/\A-?ttt\w*/i]
          token.gsub(/ttt/i, "TTT")
        elsif token.in?(RACING_ASSOCIATIONS) || token.in?(%w{ MTB SS TT TTT }) || token[/\A[A-Z][a-z]/]
          token
        else
          token.downcase.gsub(/\A[a-z]/) { $&.upcase }.gsub(/[[:punct:]][a-z]/) { $&.upcase }
        end
      end.join(" ")
    end
    name
  end

  def self.replace_roman_numeral_categories(name)
    if name
      name = name.split.map do |token|
        if token == "I"
          "1"
        elsif token == "II"
          "2"
        elsif token == "III"
          "3"
        elsif token == "IV"
          "4"
        elsif token == "V"
          "5"
        else
          token
        end
      end.join(" ")
    end
    name
  end

  def self.expand_abbreviations(name)
    if name
      name = name.split.map do |token|
        if token[/\A(cat|caat|categpry|categroy|cateogry|categegory|catgory|caegory|ct)\.?\z/i]
          "Category"
        elsif token[/\ds\z/i]
          token.gsub(/(\d)s\z/i, '\1')
        elsif token[/\Asr\.?\z/i] || token[/\Aseniors\z/i] || token[/\Asenoir\z/i]
          "Senior"
        elsif token[/\Ajr\.?\z/i] || token[/\Ajuniors\z/i] || token[/\Ajrs\.?\z/i] || token[/\Ajunior(s)?:\z/i] ||
           token[/\Ajnr\.?\z/i]
          "Junior"
        elsif token[/\Amaster\z/i] || token[/\Amas\z/i] || token[/\Amstr?\z/i] || token[/\Amaster's\z/i] ||
          token[/\Amast.?\z/i] || token[/\Amaasters\z/i] || token[/\Amastes\z/i] || token[/\Amastres\z/i] ||
          token[/\Amater\z/i] || token[/\Amaser\z/i]

          "Masters"
        elsif token[/\Amas\d\d\+\z/i]
          token.gsub(/\Amas(\d\d\+)\z/i, 'Masters \1')
        elsif token[/\Aveteran'?s\z/i] || token[/\Aveteren\z/i] || token[/\Avet\.?\z/i]
          "Veteran"
        elsif token[/\Avsty\z/i]
          "Varsity"
        elsif token[/\Aspt\z/i]
          "Sport"
        elsif token[/\Ajv\z/i]
          "Junior Varsity"
        elsif token[/\Aclydesdales\z/i] || token[/\Aclyde(s)?\z/i] || token[/\Aclydsdales\z/i]
          "Clydesdale"
        elsif token[/\Awomen'?s\z/i] || token[/\Awoman'?s\z/i]
          "Women"
        elsif token[/\Awmn?\.?\z/i] || token[/\Awom\.?\z/i] || token[/\Aw\z/i] || token[/\Awmen?\.?\z/i] || token[/\Awomenen\z/i]
          "Women"
        elsif token[/\Afemale\z/i] || token[/\Awommen:\z/i]
          "Women"
        elsif token[/\Amen'?s\z/i] || token[/\Amale\Z/i] || token[/\Amen:\z/i]
          "Men"
        elsif token[/\A\dmen\z/i]
          token.gsub(/\A(\d)men\z/i, '\1 Men')
        elsif token[/\Aco(-)?ed\z/i]
          "Co-ed"
        elsif token[/\Abeg?\.?\z/i] || token[/\Abegin?\.?\z/i] || token[/\Abeginners\z/i] || token[/\Abeg:\z/i] ||
          token[/\ABeginning\z/i]

          "Beginner"
        elsif token[/\A(exp|expt|ex|exeprt|exb|exper)\.?\z/i]
          "Expert"
        elsif token[/\Asprt\.?\z/i]
          "Sport"
        elsif token[/\Asinglespeeds?\z/i] || token[/\Ass\z/i]
          "Singlespeed"
        elsif token[/\Atand?\z/i] || token[/\Atandems\z/i]
          "Tandem"
        elsif token[/\A\d\dU\z/i]
          # 14U => U14
          token.gsub(/(\d\d)U/, 'U\1')
        elsif token[/\A\d\d>\z/i]
          # Example: Men 30> => Men 30+
          token.gsub(/(\d\d)>/, '\1+')
        elsif token == "Mdison"
          "Madison"
        elsif token == "Siixday"
          "Six-day"
        elsif token == "&"
          "and"
        else
          token
        end
      end.join(" ")

      name = name.gsub(/cat(\d+)/i, 'Category \1')
      name = name.gsub(/category(\d+)/i, 'Category \1')
      name = name.gsub(/category (\d)\/ /i, 'Category \1 ')

      name = name.gsub(/mm (\d\d)\+/i, 'Masters Men \1+')
      name = name.gsub(/\Am (\d\d)\+/i, 'Masters \1+')
      name = name.gsub(/ m (\d\d)\+/i, ' Masters \1+')
      if name[/\AM \d+/i] || name[/ M \d+/i]
        categories = name[/M (\d+)/i, 1].split("")
        name = name.gsub(/M \d+/i, "Men #{categories.join("/")}")
      end

      name = name.gsub(%r{M P/1/2}i, "Men Pro/1/2")
      name = name.gsub(%r{P/1/2}i, "Pro/1/2")

      name = name.gsub(/semi( ?)pro/i, "Semi-Pro")
      name = name.gsub(/varsity junior/i, "Junior Varsity")

      name = name.gsub(/single speeds?/i, "Singlespeed")
      name = name.gsub(/sgl spd/i, "Singlespeed")
      name = name.gsub(/sgl speed/i, "Singlespeed")

      name = name.gsub(/hard tail/i, "Hardtail")
      name = name.gsub(/hot spot/i, "Hotspot")
      name = name.gsub(/iron man/i, "Ironman")
      name = name.gsub(/multi[ -]person/i, "Multiperson")

      # 14 and Under, 14U, 14 & U
      name = name.gsub(/(\d+) (and|&) U\z/i, 'U\1')
      name = name.gsub(/(\d+)& U\z/i, 'U\1')
      name = name.gsub(/under (\d{2,3})/i, 'U\1')
      name = name.gsub(/(\d+) ?(and)? ?under/i, 'U\1')
      name = name.gsub(/(\d+) ?& ?under/i, 'U\1')
      name = name.gsub(/ 0-(\d+)/i, ' U\1')
      name = name.gsub(/ U (\d+)/i, ' U\1')

      name = name.gsub(/(\d+) ?and ?(over|older)/i, '\1+')
      name = name.gsub(/(\d+) ?& ?(over|older)/i, '\1+')

      name = name.gsub(/(\d+)\+ lbs(\.)?/i, '\1+')

      name = name.gsub(/( ?)hr( ?)/i, '\1Hour\2')
      name = name.gsub(/(\d+) hour/i, '\1-Hour')

      name = name.gsub(/ ?meter(s)?/i, "m")

      name = name.gsub(/(\d+) ?m /i, '\1m ')
      name = name.gsub(/(\d+) ?m\z/i, '\1m')
      name = name.gsub(/(\d+) ?k /i, '\1K ')
      name = name.gsub(/(\d+) ?k\z/i, '\1K')
      name = name.gsub(/(\d+) ?km/i, '\1K')

      name = name.gsub(/\d+\) ?/, "")
    end
    name
  end

  def self.normalized_name(name)
    _name = strip_whitespace(name)
    _name = split_camelcase(_name)
    _name = cleanup_punctuation(_name)
    _name = cleanup_case(_name)
    _name = replace_roman_numeral_categories(_name)
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
