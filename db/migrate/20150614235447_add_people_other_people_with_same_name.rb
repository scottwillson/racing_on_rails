class AddPeopleOtherPeopleWithSameName < ActiveRecord::Migration
  def change
    add_column :people, :other_people_with_same_name, :boolean, default: false, null: false
  end
end
