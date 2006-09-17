class Discipline  < ActiveRecord::Base

  NONE = Discipline.new(:name => "", :id => nil).freeze

  def Discipline.find_via_alias(name)
    if @aliases == nil
      load_aliases
    end
    if name == nil
      return nil
    else
      return @aliases[name.downcase]
    end
  end

  def Discipline.load_aliases
    @aliases = {}
    results = connection.select_all(
      "SELECT discipline_id, alias FROM aliases_disciplines"
    )
    for result in results
      @aliases[result["alias"].downcase] = Discipline.find(result["discipline_id"].to_i)
    end
    for discipline in Discipline.find_all
      @aliases[discipline.name.downcase] = discipline
    end
  end

  def Discipline.find_all_names
    [''] + Discipline.find_all.collect {|discipline| discipline.name}
  end

  # Which number is used for this discipline?
  # TODO Make Discipline a full-fledged class association and move method to there
  # TODO Put mapping in database
  def Discipline.number_type(discipline)
    case discipline
    when 'Cyclocross'
      :ccx_number
    when 'Mountain Bike'
      :xc_number
    when 'Downhill'
      :dh_number
    else
      :road_number
    end
  end
    
  def to_param
    name.underscore.gsub(' ', '_')
  end

  def <=>(other)
    name <=> other.name
  end  

  def to_s
    "<#{self.class} #{id} #{name}>"
  end
end
