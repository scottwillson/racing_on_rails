class AddOtherToMbraNumberIssuers < ActiveRecord::Migration
  def self.up
    return unless RacingAssociation.current.short_name == "MBRA"
    NumberIssuer.create! :name => "Other/NA"
  end

  def self.down
    return unless RacingAssociation.current.short_name == "MBRA"
    NumberIssuer.delete_all :name => "Other/NA"
  end
end
