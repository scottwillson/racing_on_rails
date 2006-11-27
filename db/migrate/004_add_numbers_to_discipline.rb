class AddNumbersToDiscipline < ActiveRecord::Migration
 def self.up
   add_column(:disciplines, :numbers, :boolean, :default => false)
   ['Cyclocross', 'Downhill', 'Mountain Bike', 'Road'].each do |name|
     discipline = Discipline.find_by_name(name)
     discipline.numbers = true
     discipline.save!
   end
   
   drop_table(:engine_schema_info)
 end
end