class RacesCollection
  include ActiveModel::Model
  attr_accessor :event
  validates_presence_of :event

  def initialize(event)
    super event: event
  end

  # To ensure a PUT when used in a form
  def persisted?
    true
  end

  def size
    event.races.size
  end

  def text
    event.races.sort.
    map do |race|
      race_text race
    end.
    join "\n"
  end

  def update(attributes)
    return true if attributes[:text].nil?

    category_attributes_by_name = parse_text attributes[:text]

    event.races.each do |race|
      if !race.name.in?(category_attributes_by_name.keys)
        race.destroy
      end
    end

    existing_category_names = event.races.map(&:name)
    new_categories = (category_attributes_by_name.keys - existing_category_names)
    new_categories.each do |name|
      event.races.create! category_attributes_by_name[name].merge(category: Category.find_or_create_by_normalized_name(name))
    end

    true
  end

  def race_text(race)
    race.name
  end

  def parse_text(text)
    category_attributes_by_name = {}

    text.split(/\r?\n/).reject(&:blank?).each do |line|
      name, attributes = parse_line(line)
      category_attributes_by_name[name] = attributes
    end

    category_attributes_by_name
  end

  def parse_line(line)
    [ line.strip, {} ]
  end
end
