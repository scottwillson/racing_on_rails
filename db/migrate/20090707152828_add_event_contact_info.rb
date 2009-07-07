class AddEventContactInfo < ActiveRecord::Migration
  def self.up
    # Earlier migration may or may not have added these columns
    begin
      change_table :events do |t|
        t.string :phone, :default => nil
        t.string :email, :default => nil
      end
    rescue Exception => e
      say e
    end
  end

  def self.down
    change_table :events do |t|
      t.remove :phone
      t.remove :email
    end
  end
end
