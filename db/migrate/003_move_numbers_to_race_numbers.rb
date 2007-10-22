class MoveNumbersToRaceNumbers < ActiveRecord::Migration
  def self.up
    Discipline.create(:name => 'Downhill', :bar => false)
    Discipline.load_aliases
    association = NumberIssuer.create(:name => ASSOCIATION.short_name)
    for racer in Racer.find(:all)
      RaceNumber.create(:value => racer[:ccx_number], :number_issuer => association, :discipline => Discipline[:cyclocross], :year => 2006, :racer => racer) unless racer[:ccx_number].blank?
      RaceNumber.create(:value => racer[:dh_number], :number_issuer => association, :discipline => Discipline[:downhill], :year => 2006, :racer => racer)  unless racer[:dh_number].blank?
      RaceNumber.create(:value => racer[:xc_number], :number_issuer => association, :discipline => Discipline[:mountain_bike], :year => 2006, :racer => racer) unless racer[:xc_number].blank?
      RaceNumber.create(:value => racer[:road_number], :number_issuer => association, :discipline => Discipline[:road], :year => 2006, :racer => racer) unless racer[:road_number].blank?
      RaceNumber.create(:value => racer[:track_number], :number_issuer => association, :discipline => Discipline[:track], :year => 2006, :racer => racer) unless racer[:track_number].blank?
    end
    remove_column(:racers, :ccx_number)
    remove_column(:racers, :dh_number)
    remove_column(:racers, :xc_number)
    remove_column(:racers, :road_number)
    remove_column(:racers, :track_number)
  end
end
