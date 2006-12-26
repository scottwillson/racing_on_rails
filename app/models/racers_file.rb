# Excel or text file of Racers. Assumes that the first row is a header row. 
# On error, logs error and continues import
class RacersFile < GridFile
  COLUMN_MAP = {
    'Birth date'                             => 'date_of_birth',
    'Address1_Contact address'               => 'street',
    'Address2_Contact address'               => 'street',
    'City_Contact address'                   => 'city',
    'State_Contact address'                  => 'state',
    'Zip_Contact address'                    => 'zip',
    'Phone'                                  => 'home_phone',
    'Road Category - '                       => 'road_category',
    'Road Age Group - '                      => 'road_category',
    'Track Category - '                      => 'track_category',
    'Track Age Group - '                     => 'track_category',
    'Cyclocross Category - '                 => 'ccx_category',
    'Cyclocross Age Group -'                 => 'ccx_category',
    'Cross Country Mountain Bike Category -' => 'mtb_category',
    'Cross Country Mountain Age Group -'     => 'mtb_category',
    'Downhill Mountain Bike Category - '     => 'dh_category',
    'Downhill Mountain Bike Age Group -'     => 'dh_category',
    'What is your occupation? (optional)'    => 'occupation',
    'Receipt Code'                           => 'notes',
    'Confirmation Code'                      => 'notes',
    'Transaction Payment Total'              => 'notes',
    'Registration Completion Date/Time'      => 'notes',
    'Donation'                               => 'notes',
    'Singlespeed'                            => 'notes',
    'Tandem'                                 => 'notes',
    'Please select a category:'              => Column.new('notes', 'Disciplines'),
    'Would you like to make an additional donation to support OBRA? '                 => Column.new('notes', 'Donation'),
    'Please indicate if you are interested in racing cross country or downhill. '     => Column.new('notes', 'Downhill/Cross Country'),
    'Please indicate if you are interested in racing single speed.'                   => Column.new('notes', 'Singlespeed'),
    'Please indicate other interests. (For example: time trial tandem triathalon r'   => Column.new('notes', 'Other interests'),
    'Your team or club name (please enter N/A if you do not have a team affiliation)' => Column.new('team_name', 'Disciplines')
  }
  
  def initialize(source, *options)
    if options.empty?
      options = Hash.new
    else
      options = options.first
    end
    options = {
      :delimiter => ',',
      :quoted => true,
      :header_row => true,
      :row_class => Racer,
      :column_map => COLUMN_MAP
    }.merge(options)
    super(source, options)
  end

  def import
    logger.debug("Import Racers")
    logger.debug("#{rows.size} rows")
    created = 0
    updated = 0

    Racer.transaction do
      begin
        for row in rows
          row_hash = row.to_hash
          logger.debug(row_hash.inspect) if logger.debug?
          combine_categories(row_hash)

          racers = Racer.find_all_by_name_or_alias(row_hash[:first_name], row_hash[:last_name])
          racer = nil
          if racers.empty?
            racer = Racer.create(row_hash)
            created = created + 1
          else
            logger.warn("RacersFile Found #{racers.size} racers for '#{row_hash[:first_name]} #{row_hash[:last_name]}'") if racers.size > 1
            row_hash[:notes] = "#{racers.last.notes}#{$INPUT_RECORD_SEPARATOR}#{row_hash[:notes]}"
            # Don't want to overwrite existing categories
            delete_blank_categories(row_hash)
            
            Racer.update(racers.last.id, row_hash)
            updated = updated + 1
          end
        end
      rescue Exception => e
        logger.error("RacersFile #{e}")
        raise
      end
    end
    return created, updated
  end
  
  def combine_categories(row_hash)
    for field in Racer::CATEGORY_FIELDS
      row_hash[field] = row_hash[field].gsub($INPUT_RECORD_SEPARATOR, ' ') if row_hash[field]
    end
  end
  
  def delete_blank_categories(row_hash)
    for field in Racer::CATEGORY_FIELDS
      row_hash.delete(field) if row_hash[field].blank?
    end
  end
  
  def logger
    RACING_ON_RAILS_DEFAULT_LOGGER
  end
end