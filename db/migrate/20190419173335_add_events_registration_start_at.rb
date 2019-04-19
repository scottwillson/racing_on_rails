class AddEventsRegistrationStartAt < ActiveRecord::Migration[5.2]
  def change
    change_table :events, force: true do |t|
      t.datetime :registration_start_at, null: true
    end
  end
end
