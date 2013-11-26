class RemoveLockVersions < ActiveRecord::Migration
  def change
    remove_column(:aliases, :lock_version) rescue puts("skipping aliases")
    remove_column(:bids, :lock_version) rescue puts("skipping bids")
    remove_column(:categories, :lock_version) rescue puts("skipping categories")
    remove_column(:discipline_aliases, :lock_version) rescue puts("skipping :discipline_aliases")
    remove_column(:disciplines, :lock_version) rescue puts("skipping aliases")
    remove_column(:editor_requests, :lock_version) rescue puts("skipping :discipline_aliases")
    remove_column(:events, :lock_version) rescue puts("skipping :events")
    remove_column(:import_files, :lock_version) rescue puts("skipping :import_files")
    remove_column(:mailing_lists, :lock_version) rescue puts("skipping :mailing_lists")
    remove_column(:names, :lock_version) rescue puts("skipping aliases")
    remove_column(:number_issuers, :lock_version) rescue puts("skipping :number_issuers")
    remove_column(:pages, :lock_version) rescue puts("skipping :pages")
    remove_column(:posts, :lock_version) rescue puts("skipping posts")
    remove_column(:race_numbers, :lock_version) rescue puts("skipping race_numbers")
    remove_column(:races, :lock_version) rescue puts("skipping races")
    remove_column(:racing_associations, :lock_version) rescue puts("skipping racing_associations")
    remove_column(:results, :lock_version) rescue puts("skipping results")
    remove_column(:teams, :lock_version) rescue puts("skipping teams")
    remove_column(:velodromes, :lock_version) rescue puts("skipping velodromes")
    
    if RacingAssociation.current.short_name == "OBRA" || RacingAssociation.current.short_name == "NABRA"
      remove_column(:adjustments, :lock_version)
      remove_column(:order_people, :lock_version)
      remove_column(:payment_gateway_transactions, :lock_version)
      remove_column(:products, :lock_version)
      remove_column(:update_requests, :lock_version)
    end
  end
end
