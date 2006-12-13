# Excel or text file of Racers. Assumes that the first row is a header row. 
# On error, logs error and continues import
class RacersFile < GridFile

  def import
    RACING_ON_RAILS_DEFAULT_LOGGER.debug("Import Racers")
    count = 0

    Racer.transaction do
      for row in rows
        racer = Racer.create(row.to_hash)
        begin
        #   cells.each_with_index do |cell, index|
        #     attribute = attributes[index]
        #     if !attribute.blank?
        #       value = trim_to_nil(cell)
        #       value = value.chomp unless value.nil?
        #       case attribute
        #       when 'obra_member_from'
        #         value = Date.strptime(value, '%m/%d/%Y') if value
        #       when 'date_of_birth'
        #         value = Date.strptime("1/1/19#{value}", '%m/%d/%Y') if value
        #       when 'team'
        #         value = Team.find_or_create_by_name(value) unless value.blank?
        #       end
        #       racer.send("#{attribute}=", value)
        #     end 
        #   end
          racer.save!
          count = count + 1
        rescue
          RACING_ON_RAILS_DEFAULT_LOGGER.warn("#{$!}: #{attribute} => #{value}")
        end
      end
      first_row = false
    end
    count
  end
end