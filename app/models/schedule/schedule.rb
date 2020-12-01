# frozen_string_literal: true

module Schedule
  # Single year's event schedule. Hierarchical model or Arrays: Schedule --> Month --> Week --> Day --> SingleDayEvent
  class Schedule
    # 0-based array of Months
    attr_reader :months, :year
    attr_accessor :events

    # Import Schedule from Excel +filename+.
    #
    # *Warning:* Deletes all events after the schedule's first event date.
    # See http://trac.butlerpress.com/racing_on_rails/wiki/SampleImportFiles for format details and examples.
    #
    # file_path = schedule file to import
    #
    # === Returns
    # * date of first event
    def self.import(file_path)
      start_date = nil
      Event.transaction do
        table = Tabular::Table.new
        table.column_mapper = ::Schedule::ColumnMapper.new
        table.read(file_path)
        table.strip!

        events = parse_events(table.rows)
        return if events.empty?

        delete_all_future_events events
        multi_day_events = find_multi_day_events(events)
        save events, multi_day_events
      end

      start_date
    end

    # Events with results _will not_ be destroyed
    def self.delete_all_future_events(events)
      date = events.map(&:date).min
      logger.debug "Delete all events after #{date}"
      # Avoid lock version errors by destroying child events first
      SingleDayEvent.where("parent_id is not null and date >= ? and events.id not in (select event_id from races)", date).destroy_all
      Event.where("date >= ? and events.id not in (select event_id from races)", date).destroy_all
    end

    # Read +rows+, split city and state, read and create promoter
    def self.parse_events(rows)
      events = []
      rows.each do |row|
        events << Schedule.parse(row) if event?(row)
      end
      events.compact
    end

    def self.event?(row)
      row[:name].present? && row[:date].present? && (row[:notes].blank? || !row[:notes]["Not on calendar"])
    end

    # Read Table Row and create SingleDayEvent
    def self.parse(row)
      logger.debug(row.inspect) if logger.debug?

      row[:instructional] = true if row[:discipline] == "Clinic"

      if row[:discipline]
        discipline = Discipline.find_via_alias(row[:discipline])
        row[:discipline] = if discipline.present?
                             discipline.name
                           else
                             RacingAssociation.current.default_discipline
                           end
      end

      if row[:sanctioned_by].nil?
        case row[:notes]
        when "national"
          row[:sanctioned_by] = "USA Cycling"
        when "international"
          row[:sanctioned_by] = "UCI"
        end
      end

      event_hash = row.to_hash
      promoter = Person.first_by_info(row[:promoter_name], row[:promoter_email], row[:promoter_phone])

      if promoter
        promoter.update!(name: row[:promoter_name]) if promoter.name.blank?

        if promoter.home_phone.blank?
          promoter.update!(home_phone: row[:promoter_phone])
        else
          event_hash[:phone] = row[:promoter_phone]
        end

        if promoter.email.blank?
          promoter.update!(email: row[:promoter_email])
        else
          event_hash[:email] = row[:promoter_email]
        end
      elsif row[:promoter_name].present? || row[:promoter_email].present? || row[:promoter_phone].present?
        promoter = Person.create!(
          name: row[:promoter_name],
          email: row[:promoter_email],
          home_phone: row[:promoter_phone]
        )
      end

      event_hash.delete :promoter_email
      event_hash.delete :promoter_phone
      event_hash[:promoter] = promoter

      event_hash.delete :series

      event_hash[:flyer_approved] = false if event_hash.key?(:flyer_approved) && event_hash[:flyer_approved].nil?

      event = SingleDayEvent.new(event_hash)

      logger.debug("Add #{event.name} to schedule") if logger.debug?
      event
    end

    # Try and create parent MultiDayEvents from imported SingleDayEvents
    def self.find_multi_day_events(events)
      logger.debug "Find multi-day events"

      # Hash of Arrays keyed by event name
      events_by_name = {}
      events.each do |event|
        logger.debug "Find multi-day events #{event.name}"
        event_array = events_by_name[event.name] || []
        event_array << event
        events_by_name[event.name] = event_array if event_array.size == 1
      end

      multi_day_events = []
      events_by_name.each do |name, event_array|
        logger.debug "Create multi-day event #{name}"
        multi_day_events << MultiDayEvent.create_from_children(event_array) if event_array.size > 1
      end

      multi_day_events
    end

    def self.add_one_day_events_to_parents(events, multi_day_events)
      events.each do |event|
        parent = multi_day_events[event.name]
        parent&.events << event
      end
    end

    def self.save(events, multi_day_events)
      events.each do |event|
        logger.debug "Save #{event.name}"
        event.save! unless Event.exists?(name: event.name, date: event.date)
      end
      multi_day_events.each do |event|
        logger.debug "Save #{event.name}"
        event.save!
        event.update_date
      end
    end

    def self.logger
      Rails.logger
    end

    # params: year, sanctioning_organization, start, end, discipline, region
    def self.find(params)
      query = if RacingAssociation.current.include_multiday_events_on_schedule?
                Event.where(parent_id: nil).where.not(type: "Event")
              else
                Event.where(type: "SingleDayEvent")
              end

      query = query.includes(:parent).includes(:promoter)

      query = query.where(practice: false) unless RacingAssociation.current.show_practices_on_calendar?

      if RacingAssociation.current.show_only_association_sanctioned_races_on_calendar?
        query = query.where(sanctioned_by: RacingAssociation.current.default_sanctioned_by)
      elsif RacingAssociation.current.filter_schedule_by_sanctioning_organization? && params[:sanctioning_organization].present?
        query = query.where(sanctioned_by: params[:sanctioning_organization])
      end

      start_date = params[:start]
      end_date = params[:end]
      unless start_date.present? && end_date.present?
        start_date = Time.zone.local(params[:year]).beginning_of_year.to_date
        end_date = Time.zone.local(params[:year]).end_of_year.to_date
      end
      query = query.where("date between ? and ?", start_date, end_date)

      query = query.where(discipline: params[:discipline].name) if params[:discipline].present?

      if RacingAssociation.current.filter_schedule_by_region?
        query = query.where(region_id: params[:region].id) if params[:region].present?
      end

      Schedule.new(params[:year], query)
    end

    def initialize(year, events)
      @year = year.to_i
      @events = events
    end

    def months
      @months ||= assign_months
    end

    def assign_months
      @months = []

      (1..12).each do |month|
        @months << Month.new(year, month)
      end

      events.each do |event|
        @months[event.date.month - 1].add event
      end

      @months
    end
  end
end
