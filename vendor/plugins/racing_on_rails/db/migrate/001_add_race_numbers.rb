class AddRaceNumbers < ActiveRecord::Migration
  def self.up
    create_table :number_issuers do |t|
      t.column :id,           :primary_key
      t.column :name,         :string,     :null => false
      t.column :lock_version, :int,        :null => false, :default => 0
      t.column :created_at,   :datetime
      t.column :updated_at,   :datetime
    end
    add_index(:number_issuers, :name, :unique => true)
    
    create_table :race_numbers do |t|
      t.column :id,               :primary_key
      t.column :racer_id,         :int,        :null => false, :on_delete => :cascade
      t.column :discipline_id,    :int,        :null => false, :on_delete => :restrict
      t.column :number_issuer_id, :int,        :null => false, :on_delete => :restrict
      t.column :value,            :string,     :null => false
      t.column :year,             :int,        :null => false
      t.column :lock_version,     :int,        :null => false, :default => 0
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end
    add_index(:race_numbers, :value)
    
    # Odd error with this one -- change with SQL
    # change_column_default(:promoters, :name, '')
    Standings.connection.execute("alter table promoters modify column name varchar(255) default '';")
    change_column(:results, :place, :string, :default => '', :limit => 8)
    change_column(:results, :number, :string, :default => '', :limit => 16)
    Standings.connection.execute('alter table standings modify column type varchar(32) default null;')
  end

  def self.down
    drop_table :race_numbers
    drop_table :number_issuers
  end
end
