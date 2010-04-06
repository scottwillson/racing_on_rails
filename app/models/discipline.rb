# Road, track, criterium, time trial ...
# TODO Add parent-child. Example: Road is parent for Criterium, Time Trial
class Discipline < ActiveRecord::Base
  include UpcomingEvents::DisciplineExtensions

  has_many :discipline_aliases
  has_and_belongs_to_many :bar_categories, :class_name => "Category", :join_table => "discipline_bar_categories"
  
  NONE = Discipline.new(:name => "", :id => nil).freeze unless defined?(NONE)
  @@all_aliases = nil
  
  # Look up Discipline by name or alias. Caches Disciplines in memory
  def Discipline.[](name)
    return nil unless name
    load_aliases unless @@all_aliases
    if name.is_a?(Symbol)
      @@all_aliases[name]
    else
      return nil if name.blank?
      @@all_aliases[name.underscore.gsub(' ', '_').to_sym]
    end
  end

  def Discipline.find_all_bar
    Discipline.find(:all, :conditions => ["bar = true"])
  end

  def Discipline.find_via_alias(name)
    Discipline[name]
  end
  
  # All Disciplines that are used for numbers. Configured in the database.
  def Discipline.find_for_numbers
    Discipline.find(:all, :conditions => 'numbers=true')
  end

  def Discipline.load_aliases
    @@all_aliases = {}
    results = connection.select_all(
      "SELECT discipline_id, alias FROM discipline_aliases"
    )
    for result in results
      @@all_aliases[result["alias"].underscore.gsub(' ', '_').to_sym] = Discipline.find(result["discipline_id"].to_i)
    end
    for discipline in Discipline.find(:all)
      @@all_aliases[discipline.name.gsub(' ', '_').underscore.to_sym] = discipline
    end
  end
  
  # Clear out cached @@aliases
  def Discipline.reset
    @@all_aliases = nil
  end
  
  def Discipline.find_all_names
    [''] + Discipline.find(:all).collect {|discipline| discipline.name}
  end
  
  def names
    case name
    when "Road"
      [nil, "", 'Circuit', "Criterium", "Road", "Time Trial", "Singlespeed", "Tour"]
    when "Mountain Bike"
      ['Downhill', 'Mountain Bike', 'Super D']
    else
      [name]
    end
  end

  # Deprecated. Should use standard Discipline names.
  def pretty_name
    (name.gsub('_', " ").gsub(/\b\w/) {|s| s.upcase })
  end

  def to_param
    @param || @param = name.underscore.gsub(' ', '_')
  end

  def <=>(other)
    name <=> other.name
  end  

  def to_s
    "<#{self.class} #{id} #{name}>"
  end
end