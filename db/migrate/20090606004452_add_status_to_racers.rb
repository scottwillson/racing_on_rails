class AddStatusToRacers < ActiveRecord::Migration
  def self.up
    case ASSOCIATION.short_name
    when "MBRA"
      return
    when "WSBA"
      add_column :people, :status, :string
    else
      add_column :racers, :status, :string
    end
  end

  def self.down
    remove_column(:people, :status) rescue nil
    remove_column(:racers, :status) rescue nil
  end
end
