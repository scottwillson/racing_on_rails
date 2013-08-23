class AddEventEndDate < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.date :end_date, :default => nil, :null => false
    end
    
    puts "Set end dates for Events"
    Event.update_all "end_date = date"
    
    puts "Set end dates for MultiDayEvents"
    Event.all.each do |event|
      putc "."
      event.update_date
    end
    puts
  end
end