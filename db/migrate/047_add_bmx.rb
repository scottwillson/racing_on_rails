class AddBmx < ActiveRecord::Migration
  def self.up
    Discipline.create!(:id => 14, :name => "BMX", :bar => false, :numbers => false)
  end

  def self.down
    Discipline.delete(14)
  end
end
