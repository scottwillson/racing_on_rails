class RemoveDuplicateNumbers < ActiveRecord::Migration
  def self.up
    racer_ids = RaceNumber.connection.select_values('select racer_id, count(value) from race_numbers group by value having count(value) > 1')
    racers = Racer.find(racer_ids)
    for racer in racers
      if racer.race_numbers.size > 1
        puts("#{racer.race_numbers.size} #{racer.name}")
        dupe_map = {}
        for number in racer.race_numbers
          for number2 in racer.race_numbers
            if number.id != number2.id && number.value == number2.value && number.discipline_id == number2.discipline_id
              unless dupe_map[number.value]
                dupe_map[number.value] = Set.new
              end
              dupe_map[number.value] << number
              dupe_map[number.value] << number2
            end
          end
        end
        for dupes in dupe_map.values
          sorted_dupes = dupes.sort_by {|number| number.id}
          for dupe in sorted_dupes
            unless dupe == sorted_dupes.first
              dupe.destroy
            end
          end
        end
      end
    end
  end
end