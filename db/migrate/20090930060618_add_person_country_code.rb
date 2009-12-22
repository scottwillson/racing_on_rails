class AddPersonCountryCode < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.change :country, :string, :limit => 2, :default => "US"
      t.rename :country, :country_code
    end
  end

  def self.down
    change_table :people do |t|
      t.rename :country_code, :country
      t.change :country, :string
    end
  end
end
