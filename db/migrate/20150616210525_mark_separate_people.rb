class MarkSeparatePeople < ActiveRecord::Migration
  def change
    Person.where(name: "Rob Anderson").update_all(other_people_with_same_name: true)
    Person.where(name: "Brian Ecker").update_all(other_people_with_same_name: true)
  end
end
