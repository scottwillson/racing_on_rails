class DuplicatePerson
  include ActiveModel::Model

  attr_accessor :id, :name

  def self.all(limit = 20)
    # Hash of people, keyed by name
    people = all_grouped_by_name(limit)
    people = sort_people_by_created_at(people)
    people = sort_names_by_created_at(people)
    flatten_people_groups(people)
  end

  def self.all_grouped_by_name(limit)
    names = new_names(duplicate_names, limit)
    Person.includes(:team, {versions: :user}).where(name: names).group_by { |p| p.name.downcase }
  end

  def self.duplicate_names
    Person.
      where(other_people_with_same_name: false).
      where("name is not null").
      where("name !=''").
      where("name !='?'").
      group(:name).
      having("count(name) > 1").
      pluck(:name).
      map(&:downcase).
      uniq
  end

  def self.new_names(names, limit)
    Person.
      where(name: names).
      order("created_at desc").
      pluck(:name).
      map(&:downcase).
      first(limit)
  end

  def self.sort_people_by_created_at(people)
    _people = Hash.new
    people.each do |name, people_for_name|
      _people[name] = people_for_name.sort_by(&:created_at).reverse
    end
    _people
  end

  def self.sort_names_by_created_at(people)
    people.sort_by { |name, people_for_name| people_for_name.first.created_at }
  end

  def self.flatten_people_groups(people)
    people.map(&:last).reverse.flatten
  end
end
