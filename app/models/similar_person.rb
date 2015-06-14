class SimilarPerson
  include ActiveModel::Model

  attr_accessor :id, :name

  def self.all
    names = names_shared_by_multiple_people
    names = newest_shared_names(names)
    # Hash of people, keyed by name
    people = all_in_names_grouped_by_name(names)
    people = sort_people_by_created_at(people)
    people = sort_names_by_created_at(people)
    flatten_people_groups(people)
  end

  def self.names_shared_by_multiple_people
    Person.
      where("name is not null").
      where("name !=''").
      group(:name).
      having("count(name) > 1").
      pluck(:name).
      map(&:downcase).
      uniq
  end

  def self.newest_shared_names(names)
    Person.
      where(name: names).
      order("created_at desc").
      pluck(:name).
      map(&:downcase).
      first(20)
  end

  def self.all_in_names_grouped_by_name(names)
    Person.includes(:team, {versions: :user}).where(name: names).group_by { |p| p.name.downcase }
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
