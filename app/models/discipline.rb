# Road, track, criterium, time trial ...
# Cached. Call +reset+ to clear cache.
class Discipline < ActiveRecord::Base
  include UpcomingEvents::DisciplineExtensions

  has_many :discipline_aliases
  has_and_belongs_to_many :bar_categories, :class_name => "Category", :join_table => "discipline_bar_categories"
  
  NONE = Discipline.new(:name => "").freeze unless defined?(NONE)
  @@all_aliases = nil
  @@names = nil
  
  scope :numbers, where(:numbers => true)
  
  # Look up Discipline by name or alias. Caches Disciplines in memory
  def self.[](name)
    return nil unless name
    load_aliases if Rails.env.acceptance? || @@all_aliases.nil?
    if name.is_a?(Symbol)
      @@all_aliases[name]
    else
      return nil if name.blank?
      @@all_aliases[name.underscore.gsub(' ', '_').to_sym]
    end
  end

  def self.find_all_bar
    Discipline.where(:bar => true)
  end

  def self.find_via_alias(name)
    Discipline[name]
  end

  def self.load_aliases
    @@all_aliases = {}
    connection.select_all("SELECT discipline_id, alias FROM discipline_aliases").each do |result|
      @@all_aliases[result["alias"].underscore.gsub(' ', '_').to_sym] = Discipline.find(result["discipline_id"].to_i)
    end
    Discipline.all.each do |discipline|
      @@all_aliases[discipline.name.gsub(' ', '_').underscore.to_sym] = discipline
    end
  end
  
  # Clear out cached @@aliases
  def self.reset
    @@all_aliases = nil
    @@names = nil
  end
  
  def self.names
    @@names ||= Discipline.all.map(&:name)
  end
  
  def names
    case name
    when "Road"
      [ nil, "", 'Circuit', "Criterium", "Road", "Time Trial", "Singlespeed", "Tour" ]
    when "Mountain Bike"
      [ 'Downhill', 'Mountain Bike', 'Super D', "Short Track" ]
    else
      [ name ]
    end
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