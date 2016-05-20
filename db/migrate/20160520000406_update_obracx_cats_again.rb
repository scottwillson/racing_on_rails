class UpdateObracxCatsAgain < ActiveRecord::Migration
  def change
    return true unless RacingAssociation.current.short_name == "OBRA"

    category_updates = {
      " Master" => "5",
      "Master" => "5",
      "/C" => "4",
      "1" => "2",
      "16" => "5",
      "2" => "3",
      "3" => "4",
      "4" => "5",
      "4/Clyde" => "5",
      "4/SS" => "5",
      "60+" => "5",
      "A, mst" => "2",
      "A/Mst" => "2",
      "A/SS" => "2",
      "Any" => "5",
      "B Senior" => "3",
      "B Sr" => "3",
      "B, Mst" => "3",
      "B/Clyd" => "3",
      "B/Mst" => "3",
      "B/SS" => "3",
      "B/UNI" => "3",
      "BBeg" => "5",
      "Be" => "5",
      "Beg" => "5",
      "Beg/ Mst 45+" => "5",
      "Beg/C" => "5",
      "Beg/Cly" => "5",
      "Beg/Clyd" => "5",
      "Beg/Clyde" => "5",
      "Beg/Jr" => "5",
      "Beg/Mst" => "5",
      "Beg/Mst 45+" => "5",
      "Beg/Mst C" => "5",
      "Beg/Mstr 50+" => "5",
      "Beg/SS" => "5",
      "Beg/Uni" => "5",
      "Brg" => "5",
      "C (Men only)" => "4",
      "C/Clyd" => "4",
      "C/Clyde" => "4",
      "C/Jr" => "4",
      "C/SS" => "4",
      "C/SSS" => "4",
      "Clyd" => "4",
      "Clyd/Beg" => "4",
      "Clyd/Mst" => "5",
      "Clyd/SS" => "5",
      "Clyde" => "5",
      "Clydes" => "5",
      "Clydesdale" => "5",
      "Jr" => "5",
      "Jr." => "5",
      "Jr/Beg" => "5",
      "Jr/C" => "4",
      "Jr/Uni" => "5",
      "Jrr" => "5",
      "Juniors" => "5",
      "Kiddie" => "5",
      "MST/A" => "2",
      "MST/B" => "3",
      "MST/C" => "4",
      "MST50/60" => "5",
      "Masters" => "5",
      "Mst" => "5",
      "Mst 45+" => "5",
      "Mst 50+" => "5",
      "Mst 50/60+" => "5",
      "Mst A" => "2",
      "Mst B" => "3",
      "Mst B/SS" => "3",
      "Mst C" => "4",
      "Mst C/C" => "4",
      "Mst C/Clyd" => "4",
      "Mst C/SS" => "4",
      "Mst W" => "5",
      "Mst/50+" => "5",
      "Mst/Clyd" => "5",
      "Mst/SS" => "5",
      "Mstr" => "5",
      "Mstr C" => "4",
      "Mstr C 35+" => "4",
      "N/A" => "5",
      "SS" => "5",
      "SS/A" => "2",
      "SS/B" => "3",
      "SS/C" => "4",
      "Singlespeed" => "5",
      "Sport" => "4",
      "Spt" => "4",
      "U" => "5",
      "Uni" => "5",
      "V" => "5",
      "Veg" => "5",
      "Wmn" => "5",
      "Wmn A" => "2",
      "Wmn Mst 45+" => "5",
      "men" => "5",
      "mst, c" => "4",
      "novice" => "5",
      "sr" => "5",
      "wmn/mst" => "5"
    }

    Person.transaction do
      category_updates.sort_by(&:last).reverse.each do |old_cat, new_cat|
        people = Person.where(ccx_category: old_cat)
        next if people.empty?

        puts ""
        puts "#{old_cat} => #{new_cat}"
        puts "-" * 80
        people.sort_by(&:name).each { |person| puts(person.name) }

        people.update_all(ccx_category: new_cat)
      end

      Person.where.not(ccx_category: "").where.not(ccx_category: nil).order(:ccx_category).group_by(&:ccx_category).each do |ccx_category, people|
        puts ""
        puts "#{ccx_category} (#{people.size})"
        puts "-" * 80
        people.sort_by(&:name).each { |person| puts(person.name) }
      end

      raise "rollback"
    end
  end
end
