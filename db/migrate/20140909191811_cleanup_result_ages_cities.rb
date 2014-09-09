class CleanupResultAgesCities < ActiveRecord::Migration
  def change
    Result.where(city: "(blank)").update_all city: nil
    Result.where(age: 0).update_all age: nil
  end
end
