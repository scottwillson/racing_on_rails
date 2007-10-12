# Abstract superclass for anything that can have standings and results:
# * SingleDayEvent
# * MultiDayEvent
# * Competition
#
# Event subclasses all share the same database table via single table inheritence, 
# so Event is not a true ActiveRecord abstract class. Event.abstract_class? returns false
class Event < ActiveRecord::Base
  before_validation :find_associated_records
  validate_on_create :validate_type
  validates_presence_of :name, :date
  after_create :add_default_number_issuer
  before_destroy :validate_no_results

  belongs_to :number_issuer
  belongs_to :promoter, :foreign_key => "promoter_id"
  has_many :standings, 
           :class_name => "Standings", 
           :dependent => :destroy, 
           :order => 'position'
           
  include Comparable
    
  # Return list of every year that has at least one event
  def Event.find_all_years
    years = []
    results = connection.select_all(
      "select distinct extract(year from date) as year from events where date <= '#{Date.today.year}-01-01'"
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

  # Defaults state to ASSOCIATION.state, date to today, name to New Event mm-dd-yyyy
  def initialize(attributes = nil)
    super
    if state == nil then write_attribute(:state, ASSOCIATION.state) end
    if self.date.nil?
      self.date = Date.today
    end
    if name == nil || name == ""
      if !date.nil?
        formatted_date = date.strftime("%m-%d-%Y")
        self.name = "New Event #{formatted_date}"
      else
        formatted_date = Date.today.strftime("%m-%d-%Y")
        self.name = "New Event #{formatted_date}"
      end
    end
    if self.sanctioned_by.blank?
      self.sanctioned_by = ASSOCIATION.short_name
    end
  end

  # Automatically applies value in promoter key to promoter.
  # Hack for OBRA legacy format: truis to guess sanctioning body from 'notes' key if sanctioned_by is missing.
  def attributes=(attributes)
    unless attributes.nil?
       if attributes[:promoter] and attributes[:promoter].is_a?(Hash)
        attributes[:promoter] = Promoter.new(attributes[:promoter])
        if attributes[:promoter_name]
          self.promoter_name = attributes[:promoter_name]
        end 
        if attributes[:promoter_email]
          self.promoter_email = attributes[:promoter_email]
        end 
        if attributes[:promoter_phone]
          self.promoter_phone = attributes[:promoter_phone]
        end                     
      end
                                       
      # Shouldn't be this tricky
      if !attributes.has_key?(:sanctioned_by)
        if attributes[:notes] == "national"
          attributes[:sanctioned_by] = "USA Cycling"
        elsif attributes[:notes] == "international"
          attributes[:sanctioned_by] = "UCI"
        end
      end
    end
    super(attributes)
  end

  # Assert that we're not trying to save an abstract class
  def validate_type
    if instance_of?(Event)
      errors.add("class", "Cannot save abstract class Event. Use MultiDayEvent or SingleDayEvent.")
    end
  end

  # TODO Could be replaced with a select join if too slow
  def validate_no_results
    for s in standings(true)
      for race in s.races(true)
        if !race.results(true).empty?
          errors.add('results', 'Cannot destroy event with results')
          return false 
        end
      end
    end
    true
  end
  
  # ASSOCIATION.short_name
  def add_default_number_issuer
    unless self.number_issuer
      self.number_issuer = NumberIssuer.find_by_name(ASSOCIATION.short_name)
      save!
    end
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
  
  # Default superclass implementation does nothing
  def after_child_event_save
  end
  
  # Default superclass implementation does nothing
  def after_child_event_destroy
  end

  # Any unsaved standings?
  def new_standings?
    for standing in standings
      if standing.new_record?
        return true  
      end
    end
    return false
  end
  
  # Update database immediately with save!
  def disable_notification!
    update_attribute('notification', false)
  end

  # Update database immediately with save!
  def enable_notification!
    update_attribute('notification', true)
  end

  # Child results fire change notifications? Set to false before bulk changes 
  # like event results import to prevent many pointless change notifications
  # and CombinedStandings recalcs
  def notification_enabled?
    self.notification
  end

  # Format for schedule page primarily
  # TODO is this used?
  def short_date
    return '' unless date
    prefix = ' ' if date.month < 10
    suffix = ' ' if date.day < 10
    "#{prefix}#{date.month}/#{date.day}#{suffix}"
  end
  
  def year
    return nil unless date
    date.year
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

  def date_range_s
    "#{date.month}/#{date.day}"
  end

  # For display in UI
  def friendly_class_name
    'Event'
  end

  def full_name
    name
  end
  
  def <=>(other)
    return -1 if other.nil?
    
    date_diff = 0
    if !date.nil? && !other.date.nil?
      date <=> other.date
    end 
    if date_diff != 0
      date_diff
    else
      name <=> other.name
    end
  end

  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{date}>"
  end

end
