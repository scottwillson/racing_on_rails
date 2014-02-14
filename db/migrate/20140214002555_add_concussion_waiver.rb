class AddConcussionWaiver < ActiveRecord::Migration
  def up
    if RacingAssociation.current.short_name == "OBRA" || RacingAssociation.current.short_name == "NABRA"
      add_column :products, :concussion_waver_required, :boolean, :default => false
      Product.reset_column_information
      team_dues = Product.where(:name => "2014 Team Dues").first
      if team_dues
        team_dues.concussion_waver_required = true
        team_dues.save!
      end
    end
  end

  def down
    if RacingAssociation.current.short_name == "OBRA"
      remove_column :products, :concussion_waver_required
    end
  end
end