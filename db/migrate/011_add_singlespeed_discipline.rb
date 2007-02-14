class AddSinglespeedDiscipline < ActiveRecord::Migration
  def self.up
    Discipline.create(:name => 'Singlespeed', :bar => false, :numbers => true)
  end

  def self.down
  end
end
