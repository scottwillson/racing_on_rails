class AddAgeGradedDiscipline < ActiveRecord::Migration
  def self.up
    Discipline.create!(:name => 'Age Graded', :bar => true, :numbers => false)
  end

  def self.down
  end
end
