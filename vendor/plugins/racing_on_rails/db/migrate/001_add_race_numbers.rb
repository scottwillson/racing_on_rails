class AddRaceNumbers < ActiveRecord::Migration
  def self.up
    create_table :number_issuers do |t|
      t.column :id,           :primary_key
      t.column :name,         :string,     :null => false
      t.column :lock_version, :int,        :null => false, :default => 0
      t.column :created_at,   :datetime
      t.column :updated_at,   :datetime
    end
    
    create_table :race_numbers do |t|
      t.column :id,               :primary_key
      t.column :racer_id,         :int,        :null => false
      t.column :discipline_id,    :int,        :null => false
      t.column :number_issuer_id, :int,        :null => false
      t.column :value,            :string,     :null => false
      t.column :year,             :int,        :null => false
      t.column :lock_version,     :int,        :null => false, :default => 0
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
      t.foreign_key :racer_id, :racers, :id, :on_delete => :cascade
      t.foreign_key :number_issuer_id, :number_issuers, :id, :on_delete => :restrict
      t.foreign_key :discipline_id, :disciplines, :id, :on_delete => :restrict
    end
    add_index(:race_numbers, :value)
    add_index(:race_numbers, [:value, :number_issuer_id, :year], :unique => true, :name => 'unique_numbers')
    
    Standings.execute('alter table standings modify column type varchar(32) default null;')
    change_column_default(:promoters, :name, '')
  end

  def self.down
    drop_table :race_numbers
    drop_table :number_issuers
  end
end
