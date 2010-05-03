class AddSuperD < ActiveRecord::Migration
  def self.up
    if ASSOCIATION.short_name == "OBRA"
      Discipline.create! :name => "Super D"
    end
  end

  def self.down
    Discipline.delete_all "name = 'Super D'"
  end
end
