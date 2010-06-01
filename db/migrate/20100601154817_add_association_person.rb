class AddAssociationPerson < ActiveRecord::Migration
  def self.up
    Person.create!(:name => ASSOCIATION.name)
  end

  def self.down
    Person.destroy_all(:first_name => ASSOCIATION.name)
  end
end
