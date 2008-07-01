class CreateVelodromes < ActiveRecord::Migration
  def self.up
    create_table :velodromes do |t|
      t.string :name
      t.string :website

      t.column :lock_version, :integer, :null => false, :default => 0
      t.timestamps
    end
    rename_column :events, :velodrome, :velodrome_name
    add_column :events, :velodrome_id, :integer
    execute("ALTER TABLE events ADD FOREIGN KEY (velodrome_id) REFERENCES velodromes (id)")
    
    SingleDayEvent.find(:all).each do |event|
      unless event.velodrome_name.blank?
        velodrome = Velodrome.find_or_create_by_name(event.velodrome_name)
        event.velodrome = velodrome
        event.save!
      end
    end
    remove_column :events, :velodrome_name
  end

  def self.down
    remove_column(:events, :velodrome_id) rescue true
    rename_column(:events, :velodrome_name, :velodrome) rescue true
    drop_table(:velodromes) rescue true
  end
end
