module Export
  module People
    include Export::Base

    def Person.export
      Person.export_head
      Person.export_data
    end

    private

    def Person.export_head
#      Base.exportFieldsFromResult(Person.find_all_for_export(Date.new, nil), "people.txt")
    end
  
    def Person.export_data
      Base.exportDataFromResult(Person.find_all_for_export(Date.new, nil), "people.csv")
    end

  end
end
