module Export
  module People
    include Export::Base

    def self.export
      Person.export_head
      Person.export_data
    end

    private

    def self.export_data
      basename = 'people.csv'
      path = Base.tmp_path basename
      path.unlink if path.exist?
      FileUtils.mkdir_p path.dirname unless path.dirname.exist?
      FileUtils.chmod 0777, path.dirname
      target = Base.public_path basename
      target.dirname.mkdir unless target.dirname.exist?

      people = Person.find_all_for_export(Date.new, nil)
      outfile = File.open(target, 'wb')
      CSV.open(outfile, "wb") do |csv|
        people.each do |person|
          person.each do |field|
            if field[1].blank?
              key=field[0]
              person[key] = '\N'
            end
          end
          csv << [person['id'], person['first_name'], person['last_name'], person['city'],
                  person['state'], person['date_of_birth'], person['license'], person['team_id'],
                  person['gender'], person['ccx_category'], person['road_category'], person['track_category'],
                  person['mtb_category'], person['dh_category']]
        end
      end

      outfile.close
    end

    def self.export_head
      Base.export(Person.export_head_sql, "people.txt")
    end

    def self.export_head_sql
      "SELECT '#{Person.export_columns.join("','")}'
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY '\\n'"
    end

    def self.export_columns
      [
        'id', "first_name", "last_name", "city", "state", "date_of_birth", "license",
        "team_id", "gender", "ccx_category", "road_category", "track_category", "mtb_category", "dh_category"
      ]
    end
  end
end
