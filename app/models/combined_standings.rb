# Standings derived from other standings: all categories in a time trial; Pro, Expert Women mountain biking
class CombinedStandings < Standings
  after_create { |standings| standings.recalculate }
  belongs_to :source, 
             :class_name => 'Standings', 
             :foreign_key => 'source_id'
  validates_presence_of :source_id
  validates_uniqueness_of :source_id, :message => "Cannot more than one CombinedStandings for same source Standings"
  validate { |standings| standings.combined_standings.nil? }

  # TODO: validate no combined_standings

  def initialize(attributes = nil)
    super
    self.source = attributes[:source]
    self.event = self.source.event
    self.event.standings << self
    self[:discipline] = self.source.discipline
    self.ironman = false
    self.bar_points = 0
    logger.debug("New #{to_s}") if logger.debug?
  end

  def name
    'Combined'
  end
  
  def ironman
    false
  end
  
  def calculate_combined_standings?
    false
  end
  
  def requires_combined_standings?
    false
  end
  
  # Do nothing -- combined_standings do not have combined_standings
  def create_or_destroy_combined_standings; end
  
  # Override in subclass
  def recalculate; end
  
  def after_source_result_save
    if self.event.notification_enabled?
      recalculate
    end
  end
  
  def after_source_result_destory
    if self.event.notification_enabled?
      recalculate
    end
  end
  
end