class ResultColumn
  attr_accessor :alignment
  attr_accessor :attribute
  attr_accessor :description
  attr_accessor :display_method
  
  def self.[](attribute)
    @@columns ||= HashWithIndifferentAccess.new({
      :age => ResultColumn.new(:age, :description => "Age"),
      :ages => ResultColumn.new(:ages, :description => "Ages"),
      :bar => ResultColumn.new(:bar, :description => "BAR"),
      :category_name => ResultColumn.new(:category_name, :description => "Category"),
      :category_class => ResultColumn.new(:category_class, :description => "Class"),
      :city => ResultColumn.new(:city, :description => "City"),
      :date_of_birth => ResultColumn.new(:date_of_birth, :description => "Date of Birth"),
      :first_name => ResultColumn.new(:first_name, :description => "First Name"),
      :gender => ResultColumn.new(:gender, :description => "Gender"),
      :laps => ResultColumn.new(:laps, :description => "Laps", :alignment => :right),
      :last_name => ResultColumn.new(:last_name, :description => "Last Name"),
      :license => ResultColumn.new(:license, :description => "Lic"),
      :name => ResultColumn.new(:name, :description => "Name"),
      :notes => ResultColumn.new(:notes, :description => "Notes"),
      :number => ResultColumn.new(:number, :description => "Num", :alignment => :right),
      :place => ResultColumn.new(:place, :description => "Pl", :alignment => :right),
      :points => ResultColumn.new(:points, :description => "Points", :alignment => :right),
      :points_bonus => ResultColumn.new(:points_bonus, :description => "Bonus", :alignment => :right),
      :points_penalty => ResultColumn.new(:points_penalty, :description => "Penalty", :alignment => :right),
      :points_from_place => ResultColumn.new(:points_from_place, :description => "Finish Pts", :alignment => :right),
      :points_total => ResultColumn.new(:points_total, :description => "Total Pts", :alignment => :right),
      :state => ResultColumn.new(:state, :description => "ST"),
      :team_name => ResultColumn.new(:team_name, :description => "Team"),
      :time => ResultColumn.new(:time, :description => "Time", :alignment => :right, :display_method => :time_s),
      :time_bonus_penalty => ResultColumn.new(:time_bonus_penalty, :description => "Bon/Pen", :alignment => :right, :display_method => :time_bonus_penalty),
      :time_gap_to_leader => ResultColumn.new(:time_gap_to_leader, :description => "Down", :alignment => :right, :display_method => :time_gap_to_leader),
      :time_gap_to_winner => ResultColumn.new(:time_gap_to_winner, :description => "Down", :alignment => :right, :display_method => :time_gap_to_winner),
      :time_total => ResultColumn.new(:time_total, :description => "Overall", :alignment => :right, :display_method => :time_total)
    })
    unless @@columns[attribute]
      @@columns[attribute] = ResultColumn.new(attribute)
    end
    @@columns[attribute]
  end
  
  def initialize(attribute, options = {})
    @alignment = options[:alignment] || :left
    @attribute = attribute
    @description = options[:description] || attribute.titleize
    @display_method = options[:display_method] || attribute
  end
end
