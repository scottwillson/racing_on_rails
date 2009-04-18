# Abstract superclass for anything that can have results:
# * SingleDayEvent
# * MultiDayEvent
# * Competition
#
# Event subclasses all share the same database table via single table inheritence, 
# so Event is not a true ActiveRecord abstract class. Event.abstract_class? returns false
#
# instructional: class or clinc
# practice: training session
class Event < ActiveRecord::Base
  PROPOGATED_ATTRIBUTES = %w{ cancelled city discipline flyer flyer_approved 
                              instructional name practice promoter_id 
                              prize_list sanctioned_by state time velodrome_id 
                              time
                             } unless defined?(PROPOGATED_ATTRIBUTES)

  before_validation :find_associated_records
  after_save :create_or_destroy_combined_results
  before_destroy :validate_no_results, :destroy_races

  validates_presence_of :name, :date
  validate :parent_is_not_self

  has_many   :competitions, :foreign_key => "source_event_id"
  belongs_to :number_issuer
  belongs_to :promoter, :foreign_key => "promoter_id"
  has_many   :races,
               :after_add => :children_changed,
               :after_remove => :children_changed 
  belongs_to :velodrome

  belongs_to :parent, 
               :foreign_key => 'parent_id', 
               :class_name => 'Event'
  
  has_many :children,
           :class_name => "Event",
           :foreign_key => "parent_id",
           :dependent => :destroy,
           :order => "date",
           :after_add => :children_changed,
           :after_remove => :children_changed 
 
  include Comparable

  # Return list of every year that has at least one event
  def Event.find_all_years
    years = []
    results = connection.select_all(
      "select distinct extract(year from date) as year from events"
    )
    results.each do |year|
      years << year.values.first.to_i
    end
    years.sort.reverse
  end
  
  # Used when importing Racers: should membership be for this year or the next?
  def Event.find_max_date_for_current_year
    # TODO Make this better
    maximum(:date, :conditions => ['date > ? and date < ?', Date.new(Date.today.year, 1, 1), Date.new(Date.today.year + 1, 1, 1)])
  end
  
  def Event.friendly_class_name
    name.underscore.humanize.titleize
  end

  def after_initialize
    set_defaults
  end
    
  # Defaults state to ASSOCIATION.state, date to today, name to New Event mm-dd-yyyy
  # NumberIssuer: ASSOCIATION.short_name
  def set_defaults
    if new_record?
      if parent.present?
        PROPOGATED_ATTRIBUTES.each { |attr| (self[attr] = parent[attr]) if self[attr].nil? }
      end
      self.bar_points = default_bar_points       if self[:bar_points].nil?
      self.date = default_date                   if self[:date].nil?
      self.discipline = default_discipline       if self[:discipline].nil?
      self.name = default_name                   if self[:name].blank?
      self.ironman = default_ironman             if self[:ironman].nil?
      self.number_issuer = default_number_issuer if number_issuer.nil?
      self.sanctioned_by = default_sanctioned_by if self[:sanctioned_by].blank?
      self.state = default_state                 if self[:state].blank?
    end
  end
  
  def default_bar_points
    1
  end
  
  def default_date
    if parent.present?
      parent.date
    else
      Date.today
    end
  end
  
  def default_discipline
    "Road"
  end
  
  def default_ironman
    1
  end
  
  def default_name
    "New Event #{self.date.strftime("%m-%d-%Y")}"
  end
  
  def default_state
    ASSOCIATION.state
  end
  
  def default_sanctioned_by
    ASSOCIATION.short_name
  end
  
  def default_number_issuer
    NumberIssuer.find_by_name(ASSOCIATION.short_name)
  end
  
  # TODO Could be replaced with a select join if too slow
  # TODO Use has_results?
  def validate_no_results
    races(true).each do |race|
      if !race.results(true).empty?
        errors.add('results', 'Cannot destroy event with results')
        return false 
      end
    end

    children(true).each do |event|
      errors.add('results', 'Cannot destroy event with children with results')
      return false unless event.validate_no_results
    end

    true
  end
  
  # Will return false-positive if there are only overall series results, but those should only exist if there _are_ "real" results.
  # The results page should show the results in that case.
  # TODO Make reload optional
  def has_results?
    self.races(true).any? { |r| !r.results(true).empty? } || children(true).any? { |event| event.has_results? }
  end
  
  # Returns only the children with +results+
  def children_with_results(reload = false)
    children(reload).select(&:has_results?)
  end
  
  # Returns only the Races with +results+
  def races_with_results
    races_copy = races.select {|race|
      !race.results.empty?
    }
    races_copy.sort!
    races_copy
  end

  def destroy_races
    self.races.each(&:destroy)
    races.clear
  end

  # TODO Remove. Old workaround to ensure children are cancelled
  def find_associated_records
    existing_discipline = Discipline.find_via_alias(discipline)
    self.discipline = existing_discipline.name unless existing_discipline.nil?
  
    if self.promoter
      if self.promoter.name.blank? and self.promoter.email.blank? and self.promoter.phone.blank?
        self.promoter = nil
      else
        existing_promoter = Promoter.find_by_info(self.promoter.name, self.promoter.email, self.promoter.phone)
        if existing_promoter
          self.promoter = existing_promoter
        end
      end
    end
  end
  
  # Update child events from parents' attributes if child attribute has the
  # same value as the parent before update
  # TODO original_values is duplicating Rails 2.1's dirty
  def update_children(force = false)
    return if new_record?
    
    original_values = Event.connection.select_one("select #{PROPOGATED_ATTRIBUTES.join(', ')} from events where id = #{self.id}")
    for attribute in PROPOGATED_ATTRIBUTES
      original_value = original_values[attribute]
      new_value = self[attribute]
      RACING_ON_RAILS_DEFAULT_LOGGER.debug("Event update_children #{attribute}, #{original_value}, #{new_value}")
      if force
        Event.update_all(
          ["#{attribute}=?", new_value], 
          ["parent_id=?", self[:id]]
        )
      elsif original_value.nil?
        Event.update_all(
          ["#{attribute}=?", new_value], 
          ["#{attribute} is null and parent_id=?", self[:id]]
        ) unless original_value == new_value
      else
        Event.update_all(
          ["#{attribute}=?", new_value], 
          ["#{attribute}=? and parent_id=?", original_value, self[:id]]
        ) unless original_value == new_value
      end
    end
    
    children.each { |child| child.update_children(force) }
    true
  end

  def children_changed(child)
    touch!
  end
  
  def touch!
    ActiveRecord::Base.lock_optimistically = false
    update_attribute(:updated_at, Time.now)
    ActiveRecord::Base.lock_optimistically = true
    true
  end

  # Update database immediately with save!
  def disable_notification!
    ActiveRecord::Base.lock_optimistically = false
    update_attribute('notification', false)
    ActiveRecord::Base.lock_optimistically = true
  end

  # Update database immediately with save!
  def enable_notification!
    ActiveRecord::Base.lock_optimistically = false
    update_attribute('notification', true)
    ActiveRecord::Base.lock_optimistically = true
  end

  # Child results fire change notifications? Set to false before bulk changes 
  # like event results import to prevent many pointless change notifications
  # and CombinedTimeTrialResults recalcs
  def notification_enabled?
    self.notification
  end

  # Adds +combined_results+ if Time Trial Event. 
  # Destroy +combined_results+ if they exist, but should not
  def create_or_destroy_combined_results
    if !self.calculate_combined_results? || !has_results? || (self.combined_results(true) && combined_results.discipline != discipline)
      destroy_combined_results
    end
    
    if calculate_combined_results? && combined_results(true).nil? && has_results?
      if discipline == 'Time Trial'
        CombinedTimeTrialResults.create(:parent => self)
      end      
    end
    combined_results(true)
  end
  
  def combined_results(reload = false)
    self.children(reload).detect { |event| event.is_a?(CombinedTimeTrialResults) }
  end
  
  def calculate_combined_results?
    auto_combined_results? && requires_combined_results?
  end
  
  def requires_combined_results?
    false
  end

  def destroy_combined_results
    if self.combined_results(true)
      combined_results.destroy_races
      self.children.delete(combined_results)
    end
  end
  
  #FIXME Need common Overall subclass for Cascade Cross and Tabor
  def overall(reload = false)
    self.competitions(reload).detect { |competition| competition.is_a?(Overall) }
  end
  
  # Format for schedule page primarily
  # TODO is this used?
  def short_date
    return '' unless date
    prefix = ' ' if date.month < 10
    suffix = ' ' if date.day < 10
    "#{prefix}#{date.month}/#{date.day}#{suffix}"
  end

  # +date+
  def start_date
    date
  end
  
  def start_date=(date)
    self.date = date
  end
  
  def end_date
    if !children(true).empty?
      children.last.date
    else
      start_date
    end
  end
  
  def year
    return nil unless date
    date.year
  end

  def multiple_days?
    end_date > start_date
  end
  
  def city_state
    if !city.blank?
      if !state.blank?
        "#{city}, #{state}"
      else
        city
      end
    else
      if !state.blank?
        state
      else
        ''
      end
    end
  end
  
  def location
    self.city_state
  end

  def discipline_id
    Discipline[discipline].id if Discipline[discipline]
  end
  
  def flyer
    unless self[:flyer].blank?
      if self[:flyer][/^\//]
        return 'http://' + STATIC_HOST + self[:flyer]
      elsif self[:flyer][/^..\/..\//]
        return 'http://' + STATIC_HOST + (self[:flyer][/^..\/..(.*)/, 1])
      end
    end
    self[:flyer]
  end
  
  def promoter_name
    promoter.name if promoter
  end

  def promoter_name=(value)
    if promoter.nil?
      self.promoter = Promoter.new
    end
    self.promoter.name = value
  end

  def promoter_email
    promoter.email if promoter
  end

  def promoter_email=(value)
    if promoter.nil?
      self.promoter = Promoter.new
    end
    self.promoter.email = value
  end

  def promoter_phone
    promoter.phone if promoter
  end

  def promoter_phone=(value)
    if promoter.nil?
      self.promoter = Promoter.new
    end
    self.promoter.phone = value
  end

  def date_range_s(format = :short)
    if format == :long
      date.strftime('%m/%d/%Y')
    else
      "#{date.month}/#{date.day}"
    end
  end

  def date_range_long_s
    date.strftime('%a, %B %d')
  end

  def full_name
    if parent.nil?
      name
    elsif parent.full_name == name
      name
    elsif name[parent.full_name]
      name
    else
      "#{parent.full_name}: #{name}"
    end
  end


  # Only SingleDayEvent subclass has a parent -- this abstract class, Event, does not have a
  # parent, but implementing missing_parent? here allows clients to just call the method
  # without first checking that it exists
  def missing_parent?
    false
  end

  # Only MultiDayEvent subclass has children -- this abstract class, Event, does not have 
  # children, but implementing missing_children? here allows clients to just call the method
  # without first checking that it exists
  def missing_children?
    !missing_children.empty?
  end
  
  # Only MultiDayEvent subclass has children -- this abstract class, Event, does not have 
  # children, but implementing missing_children? here allows clients to just call the method
  # without first checking that it exists
  def missing_children
    []
  end
  
  def multi_day_event_children_with_no_parent?
    !multi_day_event_children_with_no_parent.empty?
  end
  
  def multi_day_event_children_with_no_parent
    @multi_day_event_children_with_no_parent ||= SingleDayEvent.find(
      :all, 
      :conditions => [
        "parent_id is null and name = ? and extract(year from date) = ? 
         and ((select count(*) from events where name = ? and extract(year from date) = ? and type in ('MultiDayEvent', 'Series', 'WeeklySeries')) = 0)",
         self.name, self.date.year, self.name, self.date.year])
    # Could do this in SQL
    if @multi_day_event_children_with_no_parent.size == 1
      @multi_day_event_children_with_no_parent = []
    end
    @multi_day_event_children_with_no_parent
  end
    
  def missing_parent
    nil
  end
  
  # TODO Use acts as tree
  def root
    node = self
    node = node.parent while node.parent
    node
  end

  def ancestors
    node, nodes = self, []
    nodes << node = node.parent while node.parent
    nodes
  end

  def parent_is_not_self
    if parent_id && parent_id == id
      errors.add("parent", "Event cannot be its own parent")
    end
  end

  def friendly_class_name
    self.class.friendly_class_name
  end
  
  def <=>(other)
    return -1 if other.nil?
    
    return 0 if id == other.id
    
    if date && other.date
      date <=> other.date
    else
      0
    end 
  end
  
  def inspect_debug
    puts("#{self.class.name.ljust(20)} #{self.date} #{self.name} #{self.discipline} #{self.id}")
    self.races(true).each {|r| 
      puts("#{r.class.name.ljust(20)}   #{r.name}")
      r.results(true).sort.each {|result|
        puts("#{result.class.name.ljust(20)}      #{result.to_long_s}")
        result.scores(true).each{|score|
          puts("#{score.class.name.ljust(20)}         #{score.source_result.place} #{score.source_result.race.event.name}  #{score.source_result.race.name} #{score.points}")
        }
      }
    }
    
    self.children(true).each do |event|
      event.inspect_debug
    end
    
    ""
  end

  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{date}>"
  end
end
