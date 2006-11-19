# Excel or text file of Racers. Assumes that the first row is a header row. 
# On error, logs error and continues import
class RacersFile

  def initialize(filename)
    @filename = filename
  end
  
  def import(progress_monitor = NullProgressMonitor.new)
    RACING_ON_RAILS_DEFAULT_LOGGER.debug("Import Racers")
    progress_monitor.text = "Import Racers"
    progress_monitor.detail_text = "Reading #{@filename}"
    progress_monitor.increment(1)
    rows = IO.readlines(@filename, "\n")
    progress_monitor.increment(1)

    progress_monitor.total = rows.size + 3
    progress_monitor.detail_text = "#{rows.size} rows"
    RACING_ON_RAILS_DEFAULT_LOGGER.debug("#{rows.size} rows")
    Racer.transaction do
      first_row = true
      for row in rows
        if first_row
          attributes = row.split("\t")
          attributes = attributes.collect do |attribute|
            attribute.chomp
          end
        else
          racer = Racer.new
          cells = row.split("\t")
          attribute = nil
          value = nil
          begin
            cells.each_with_index do |cell, index|
              attribute = attributes[index]
              if !attribute.blank?
                value = trim_to_nil(cell)
                value = value.chomp unless value.nil?
                case attribute
                when 'obra_member_on'
                  value = Date.strptime(value, '%m/%d/%Y') if value
                when 'date_of_birth'
                  value = Date.strptime("1/1/19#{value}", '%m/%d/%Y') if value
                when 'team'
                  value = Team.find_or_create_by_name(value) unless value.blank?
                end
                racer.send("#{attribute}=", value)
              end 
            end
            racer.save!
          rescue
            RACING_ON_RAILS_DEFAULT_LOGGER.warn("#{$!}: #{attribute} => #{value}")
          end
          progress_monitor.detail_text = racer.name
          progress_monitor.increment(1)
        end
        first_row = false
      end
    end
  end

  def trim_to_nil(string)
    string.strip! unless string == nil
    if string == ""
      string = nil
    end
    return string
  end

end