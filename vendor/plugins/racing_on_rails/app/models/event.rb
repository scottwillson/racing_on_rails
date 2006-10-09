# Abstract class
class Event < ActiveRecord::Base

    before_validation :find_associated_records
    validate_on_create :validate_type
    validates_presence_of :name, :date

    belongs_to :promoter, :foreign_key => "promoter_id"
    has_many :standings, 
             :class_name => "Standings", 
             :dependent => :destroy, 
             :order => 'position'
           
    def Event.find_all_years
      extract_year_sql = "extract(year from date)"
      if connection.adapter_name == "SQLite"
        extract_year_sql = "strftime('%Y', date)"
      end
      years = []
      results = connection.select_all(
        "select distinct #{extract_year_sql} as year from events"
      )
      results.each do |year|
        years << year.values.first.to_i
      end
      years.sort.reverse
    end

    def initialize(attributes = nil)
      super
      if state == nil then write_attribute(:state, ASSOCIATION.state) end
      if date.nil?
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
  
    def validate_type
      if instance_of?(Event)
        errors.add("class", "Cannot save abstract class Event. Use MultiDayEvent or SingleDayEvent.")
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
    
    def after_child_event_save
    end
    
    def after_child_event_destroy
    end

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
      self.notification = false
      save!
    end

    # Update database immediately with save!
    def enable_notification!
      self.notification = true
      save!
    end
  
    # Child results fire change notifications? Set to false before bulk changes 
    # like event results import to prevent many pointless change notifications
    # and CombinedStandings recalcs
    def notification_enabled?
      self.notification
    end
  
    # Format for schedule page primarily
    def short_date
      return '' unless date
      prefix = ' ' if date.month < 10
      suffix = ' ' if date.day < 10
      "#{prefix}#{date.month}/#{date.day}#{suffix}"
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
  
    def friendly_class_name
      'Event'
    end
  
    def <=>(other)
      date_diff = date <=> other.date
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
