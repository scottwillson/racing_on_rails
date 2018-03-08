class EnlargeRegistrationLink < ActiveRecord::Migration
  def change
    change_column :events, :registration_link, :string, limit: 1024
  end
end
