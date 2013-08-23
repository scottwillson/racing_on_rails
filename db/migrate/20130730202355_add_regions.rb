class AddRegions < ActiveRecord::Migration
  def change
    create_table :regions, :force => true do |t|
      t.string :name, :null => false, :default => nil
      t.string :friendly_param, :null => false, :default => nil
      t.timestamps
    end
    
    add_index :regions, :name, :unique => true
    add_index :regions, :friendly_param, :unique => true

    change_table :racing_associations do |t|
      t.boolean :filter_schedule_by_region, :default => false, :null => false
      t.string :default_region_id
    end
    
    change_table :events do |t|
      t.integer :region_id, :default => nil
    end
    
    add_index :events, :region_id
    
    if RacingAssociation.current.short_name == "NABRA"
      [ "Washington", "Oregon", "N. California", "S. California", "Idaho" ].each do |name|
        Region.create! :name => name
      end
      
      ra = RacingAssociation.current
      ra.default_region_id = Region.where(:name => "Oregon").first
      
      Event.update_all(:region_id => Region.where(:name => "Oregon").first.id)
    end
  end
end