module Results
  class LifFile
    attr_reader :event, :race, :table

    def initialize(path, event)
      @event = event
      @table = Tabular::Table.read(path, :as => :csv, :columns => ResultsFile::COLUMN_MAP)
    end
    
    def import
      Event.transaction do
        event.disable_notification!
        
        table.rows.each do |row|
          find_or_create_race row
          create_result row
        end
        
        event.enable_notification!
        CombinedTimeTrialResults.create_or_destroy_for!(event)
      end
    end
    
    def find_or_create_race(row)
      return true if race
      
      category = Category.find_or_create_by_name(row[:category_name])
      @race = event.races.detect { |race| race.category == category }
      if race
        race.results.clear
      else
        @race = event.races.build(:category => category)
      end
      race.result_columns = table.columns.map { |column| column.key.to_s }
      race.save!
    end
    
    def create_result(row)
      result = race.results.build(row.to_hash)
      result.updated_by = event.name
      result.place = row.index + 1

      result.cleanup
      result.save!
    end
    
    # For ResultFile compatibility
    def custom_columns
      []
    end
  end
end
