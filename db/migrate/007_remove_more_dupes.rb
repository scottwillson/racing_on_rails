class RemoveMoreDupes < ActiveRecord::Migration
  def self.up
    racer_ids = RaceNumber.connection.select_values('select racer_id, count(value) from race_numbers group by racer_id having count(value) > 1 order by racer_id')
    racers = Racer.find(racer_ids)
    for racer in racers
      if racer.race_numbers.size > 1
        puts('-------------------------------')
        puts("#{racer.race_numbers.size} #{racer.name}")
        puts('-------------------------------')
        dupe_map = {}
        for number in racer.race_numbers
          puts(number)
          for number2 in racer.race_numbers
            if (number.id != number2.id) && (number.value == number2.value)
              unless dupe_map[number.value]
                dupe_map[number.value] = Set.new
              end
              dupe_map[number.value] << number
              dupe_map[number.value] << number2
            end
          end
        end
        puts('- - - - - - - - - - - - - - - - ')
        for dupes in dupe_map.values.clone
          for dupe in dupes
            puts(dupe)
            unless dupe.discipline.id == 1
              puts("#{dupe} destroy")
    	  dupe.destroy
    	  dupe_map.delete(dupe.value)
            end
          end
        end
        puts('- - - - - - - - - - - - - - - - ')
        for dupes in dupe_map.values
          puts(dupe)
          sorted_dupes = dupes.sort_by {|number| number.id}
          for dupe in sorted_dupes
            unless dupe == sorted_dupes.first
              puts("#{dupe} destroy")
    	        dupe.destroy
            end
          end
        end
      end
    end
  end
end