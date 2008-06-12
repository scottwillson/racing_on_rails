module Schedule
  # Single year's event schedule. Hierarchical model or Arrays: Schedule --> Month --> Week --> Day --> SingleDayEvent
  class Schedule

    # FIXME Remove dependency. Is it here because we need a helper?
    include ActionView

    # 0-based array of Months
    attr_reader :months, :year

    # Import Schedule from Excel +filename+.
    #
    # *Warning:* Deletes all events after the schedule's first event date
    #
    # Rigid OBRA legacy format (skip first row):
    # 0. _skip_
    # 1. _skip_
    # 2. _skip_
    # 3. date
    # 4. _skip_
    # 5. name
    # 6. city
    # 7. promoter_name
    # 8. promoter_phone
    # 9. promoter_email
    # 10. discipline
    # 11. notes
    #
    # Import implemented in several methods. See source code.
    # === Returns
    # * date of first event
    def Schedule.import(filename)
      date = nil
      Event.transaction do
        file             = read_file(filename)
        date             = read_date(file)
                           delete_all_future_events(date)
        events           = parse_events(file)
        multi_day_events = find_multi_day_events(events)
                           save(events, multi_day_events)
      end
      date
    end
    
    def Schedule.read_date(file)
      date             = file.rows.first['date']
      logger.debug("Schedule Import starting at #{date}")
      Date.parse(date)
    end
    
    def Schedule.delete_all_future_events(date)
      logger.debug("Delete all events after #{date}")
      Event.destroy_all(["date >= ?", date])
    end
    
    # Create GridFile from Excel
    def Schedule.read_file(filename)
      logger.debug("Read #{filename}")
      GridFile.new(
        File.new(filename), 
        :columns => ["", "", "", "date", "", "name", "city", "promoter_name", "promoter_phone", "promoter_email", "discipline", Column.new(:name => 'notes', :description => 'Notes')]
      )
    end

    # Read GridFile +file+, split city and state, read and create promoter
    def Schedule.parse_events(file)
      events = []
      for row in file.rows
        row_hash = row.to_hash

        if has_event?(row_hash)
          split_city_state(row_hash)
          event = Schedule.parse(row_hash)
          if event != nil
            # Save to persist new promoters (if there is one)
            # to prevent duplicate promoters in memory
            # TODO Check for dupe promoters at save time instead
            event.find_associated_records
            if event.promoter
              event.promoter.save! 
            end
            events << event
          end
        end
      end
      return events
    end

    def Schedule.has_event?(row_hash)
      name = row_hash[:name]
      date = row_hash[:date]
      return (!name.blank? and !date.blank?)
    end

    # Split location on comma
    def Schedule.split_city_state(row_hash)
      city = row_hash[:city]
      state = row_hash[:state]
      if !city.nil? and (state == "" or state.nil?)
        city, state = city.split(",")
        city.strip! unless city.nil?
        row_hash[:city] = city
        state.strip! unless state.nil?
        row_hash[:state] = state
      end
    end

    # Read GridFile Row and create SingleDayEvent
    def Schedule.parse(row_hash)
      logger.debug(row_hash.inspect) if logger.debug?
      event = nil
      if !(row_hash[:date].blank? and row_hash[:name].blank?)
        begin
          row_hash[:date] = Date.strptime(row_hash[:date], "%Y-%m-%d")
        rescue
          logger.warn($!)
          row_hash[:date] = nil
        end
        if row_hash[:discipline]
          discipline = Discipline.find_via_alias(row_hash[:discipline])
          if discipline != nil
            row_hash[:discipline] = discipline.name
          else
            row_hash[:discipline] = ASSOCIATION.default_discipline
          end
        end
        
        if !row_hash.has_key?(:sanctioned_by)
          if row_hash[:notes] == 'national'
            row_hash[:sanctioned_by] = 'USA Cycling'
          elsif row_hash[:notes] == 'international'
            row_hash[:sanctioned_by] = 'UCI'
          end
        end

        event = SingleDayEvent.new(row_hash)
        if logger.debug? then logger.debug("Add #{event.name} to schedule") end
      end
      return event
    end

    # Try and create parent MultiDayEvents from imported SingleDayEvents
    def Schedule.find_multi_day_events(events)
      logger.debug("Find multi-day events")

      # Hash of Arrays keyed by event name
      events_by_name = Hash.new
      for event in events
        logger.debug("Find multi-day events #{event.name}")
        event_array = events_by_name[event.name] || Array.new
        event_array << event
        events_by_name[event.name] = event_array if event_array.size == 1
      end
  
      multi_day_events = []
      for key_value in events_by_name
        name, event_array = key_value
        logger.debug("Create multi-day event #{name}")
        if event_array.size > 1
          multi_day_events << MultiDayEvent.create_from_events(event_array)
        end
      end
  
      return multi_day_events
    end

    def Schedule.add_one_day_events_to_parents(events, multi_day_events)
      for event in events
        parent = multi_day_events[event.name]
        if !parent.nil?
          parent.events << event
        end
      end
    end

    def Schedule.save(events, multi_day_events)
      for event in events
        logger.debug("Save #{event.name}")
        event.save!
      end
      for event in multi_day_events
        logger.debug("Save #{event.name}")
        event.save!
      end
    end
    
    def Schedule.logger
      RAILS_DEFAULT_LOGGER
    end

    def initialize(year, events)
      @year = year.to_i
      @months = []
      for month in 1..12
        @months << Month.new(year, month)
      end
      for event in events
        month = @months[event.date.month - 1]
        if month.nil?
          raise(IndexError, "Could not find month for #{event.date.month} in year #{year}")
        end
        month.add(event)
      end
    end
  end

  # Hash that keeps a count for each key
  class HashBag < Hash

    def initialize
      @counts = {}
      super
    end

    def []=(key, value)
      count = count(key)
      count = count + 1
      @counts[key] = count
      super
    end

    def count(key)
      count = @counts[key]

      if count != nil
        count    
      else
        0
      end
    end
  end
end
