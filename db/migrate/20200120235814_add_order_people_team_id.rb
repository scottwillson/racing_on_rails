class AddOrderPeopleTeamId < ActiveRecord::Migration[5.2]
  def change
    change_table :order_people do |t|
      t.belongs_to :team, foreign_key: true, type: :integer
    end
  end
end
