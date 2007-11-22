# TODO improve naming. Attribute keys? Hash keys?
# Senior Men Pro 1/2 | Field size: 79 riders | Laps: 2 
class ResultsFile < GridFile

  attr_accessor :invalid_columns

  COLUMN_MAP = {
    "#" => "number",
    "wsba#" => "number",
    "rider_#" => "number",
    'racing_age' => 'age',
    "barcategory" => "parent",
    "bar_category" => "parent",
    "category.name" => "category_name",
    "categories" => "category_name",
    "category" => "category_name",
    "cat." => "category_name",
    "first" => "first_name",
    "firstname" => "first_name",
    "racer.first_name" => "first_name",
    "racer" => "name",
    "last" => "last_name",
    "lastname" => "last_name",
    "racer.last_name" => "last_name",
    "team" => "team_name",
    "team.name" => "team_name",
    "obra_number" => "number",
    "oregoncup" => "oregon_cup",
    "membership #" => "license",
    "membership" => "license",
    "last name" => "last_name",
    "first name" => "first_name",
    "club/team" => "team_name",
    "hometown" => 'city',
    "stage_time" => "time",
    "bonus" => "time_bonus_penalty",
    "penalty" => "time_bonus_penalty",
    "stage_+_penalty" => "time_total",
    "time" => "time",
    "time_total" => "time_total",
    "total_time" => "time_total",
    "down" => "time_gap_to_leader",
    "gap" => "time_gap_to_leader",
    "pts" => "points"
  }

  def ResultsFile.cyclocross_workbook?(source, event)
    if event and event.discipline == 'Cyclocross' and (source.is_a?(File) or source.is_a?(Tempfile)) and source.path.include?('.xls')
      workbook = Spreadsheet::ParseExcel.parse(source.path)
      return workbook.sheet_count > 6
    end
    false
  end

  def initialize(source, event, *options)
    @invalid_columns = []
    @event = event
    if options.empty?
      options = Hash.new
    else
      options = options.first
    end
    if ResultsFile.cyclocross_workbook?(source, event)
      @cyclocross_workbook = true
      options =  {:columns => ['number', '', '', '', '', '', '', '', '', '', '', '', '', 'last_name', 'first_name', 'team_name', 'city', 'category', 'laps', 'place'], 
                  :column_map => COLUMN_MAP,
                  :row_class => Result}.merge(options)
      super(source, options)
    else
      options = {:header_row => true, :column_map => COLUMN_MAP, :row_class => Result}.merge(options)
      super(source, options)
    end
    RACING_ON_RAILS_DEFAULT_LOGGER.debug("columns: #{@columns.inspect}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
    delete_blank_rows
  end
  
  def after_columns_created
    unless @cyclocross_workbook
      if !columns.empty? and columns.first.name.blank?
        columns.first.name = 'place'
        columns.first.field = :place
      end
    end
  end

  def import
    RACING_ON_RAILS_DEFAULT_LOGGER.info("import results")

    standings = nil
    begin
      @event.disable_notification!
      standings = Standings.create!(
        :event => @event,
        :name => @event.name
      )
      result_columns = columns.collect do |column|
        # Remove invalid columns
        column.field.to_s unless column.field.nil?
      end
      result_columns.delete_if do |column|
        column.blank?
      end
      category = nil
      race = nil
      previous_place = nil
      rows.each_with_index do |row, index|
        continue if row.blank?
        row_hash = row.to_hash
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("import #{row_hash.inspect}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug? 
        if new_race?(row_hash, index)
          if @cyclocross_workbook
            category = Category.new(:name => rows[index - 1].first)
            race = standings.races.create(:category => category, :notes => to_notes(rows[index - 1]))
          else
            category = Category.new(:name => row.first)
            race = standings.races.create(:category => category, :notes => to_notes(row))
          end
          race.result_columns = result_columns
          if race.result_columns.include?('name')
            name_index = race.result_columns.index('name')
            race.result_columns[name_index] = 'first_name'
            race.result_columns.insert(name_index + 1, 'last_name')
          end
          if race.result_columns.include?('place') and race.result_columns.first != 'place'
            race.result_columns.delete('place')
            race.result_columns.insert(0, 'place')
          end
          race.save!
          RACING_ON_RAILS_DEFAULT_LOGGER.info("ResultsFile import race #{category}")
        elsif has_results?(row_hash)
          if race
            result = race.results.build(row_hash)
            if race.nil? and result.place and result.place.to_i == 1
              race = standings.races.create(:category => category)
              result.race = race
            end
            if row_hash[:time] and !row_hash[:time].include?(':')
              result.time = result.time.to_f
            end
            if row_hash[:time_bonus_penalty] and !row_hash[:time_bonus_penalty].include?(':')
              result.time_bonus_penalty = result.time_bonus_penalty.to_f
            end
            if row_hash[:time_total] and !row_hash[:time_total].include?(':')
              result.time_total = result.time_total.to_f
            end
            if row_hash[:time_gap_to_leader] and !row_hash[:time_gap_to_leader].include?(':')
              result.time_gap_to_leader = result.time_gap_to_leader.to_f
            end
        
            if result.place.to_i > 0
        			result.place = result.place
        		elsif !result.place.blank?
        			result.place = result.place.upcase
        		elsif !previous_place.blank?
        		  result.place = 'DNF'
        		else
              result.place = previous_place
        		end
            previous_place = result.place

            result.cleanup
            result.save!
            RACING_ON_RAILS_DEFAULT_LOGGER.debug("#{race} #{result.place}")
          else
            RACING_ON_RAILS_DEFAULT_LOGGER.debug("No race. Skip.")
          end
        end
      end
      @event.enable_notification!
      # TODO Not so clean
      standings.create_or_destroy_combined_standings
      standings.combined_standings.recalculate if standings.combined_standings
     rescue Exception => error
      begin
        standings.destroy if standings
      rescue Exeception => cleanup_error
        OBRA_LOGGER.warn("Problem cleaning up after failed import: #{cleanup_error}")
      ensure
        standings = nil
        raise error
      end
    end
    standings
  end

  def has_results?(row_hash)
    if @cyclocross_workbook and !row_hash[:number].blank? and row_hash.size == 1
      return false
    end
    return false if row_hash == nil or row_hash.empty?
    return true if !row_hash[:place].blank?
    return true if !row_hash[:number].blank?
    return true if !row_hash[:license].blank?
    if !row_hash[:team_name].blank?
      return true
    end
    if !(row_hash[:first_name].blank? and row_hash[:last_name].blank? and row_hash[:name].blank?)
      return true
    end
    false
  end

  def new_race?(row_hash, index)
    # last row?
    return false unless index < rows.size
    
    if @cyclocross_workbook
      return row_hash[:number] == 'Number'
    else
      next_row = rows[index + 1]
      return false if row_hash.nil? or row_hash.empty? or next_row.nil? or next_row.empty?

      place_cell = row_hash[:place]
      place_cell_next_row = rows[index + 1].to_hash[:place]
      return false unless  place_cell.to_i == 0
      place_cell_next_row.to_i == 1
    end
  end

  def to_notes(row)
    return '' if row.nil? or row.size < 2
    row[1, row.size - 1].select {|cell| !cell.blank?}.join(", ")
  end
end
