class AddRacingAssociations < ActiveRecord::Migration
  def self.up
    create_table :racing_associations, :force => true do |t|
      t.boolean :add_members_from_results, :default                           => true, :null => false
      t.boolean :always_insert_table_headers, :default                        => true, :null => false
      t.boolean :award_cat4_participation_points, :default                    => true, :null => false
      t.boolean :bmx_numbers, :default                                        => false, :null => false
      t.boolean :cx_memberships, :default                                     => false, :null => false
      t.boolean :eager_match_on_license, :default                             => false, :null => false
      t.boolean :flyers_in_new_window, :default                               => false, :null => false
      t.boolean :gender_specific_numbers, :default                            => false, :null => false
      t.boolean :include_multiday_events_on_schedule, :default                => false, :null => false
      t.boolean :show_calendar_view, :default                                 => true, :null => false
      t.boolean :show_events_velodrome, :default                              => true, :null => false
      t.boolean :show_license, :default                                       => true, :null => false
      t.boolean :show_only_association_sanctioned_races_on_calendar, :default => true, :null => false
      t.boolean :show_practices_on_calendar, :default                         => false, :null => false
      t.boolean :ssl, :default                                                => false, :null => false
      t.integer :cat4_womens_race_series_category_id
      t.integer :lock_version, :default                                       => 0, :null => false
      t.integer :masters_age, :default                                        => 35, :null => false
      t.integer :rental_numbers_end, :default                                 => 99, :null => false
      t.integer :rental_numbers_start, :default                               => 51, :null => false
      t.string  :cat4_womens_race_series_points
      t.string :administrator_tabs
      t.string :competitions
      t.string :country_code, :default                                        => "US", :null => false
      t.string :default_discipline, :default                                  => "Road", :null => false
      t.string :default_sanctioned_by
      t.string :email, :default                                               => "scott.willson@gmail.com", :null => false
      t.string :exempt_team_categories, :default                              => false, :null => false
      t.string :membership_email, :default                                    => "scott.willson@gmail.com", :null => false
      t.string :name, :default                                                => "Cascadia Bicycle Racing Association", :null => false
      t.string :sanctioning_organizations
      t.string :short_name, :default                                          => "CBRA", :null => false
      t.string :show_events_sanctioning_org_event_id, :default                => false, :null => false
      t.string :state, :default                                               => "OR", :null => false
      t.string :usac_region, :default                                         => "North West", :null => false
      t.string :usac_results_format, :default                                 => false, :null => false
      t.timestamps
    end
    
    RacingAssociation.reset_column_information
    RacingAssociation.create!
  end

  def self.down
    drop_table :racing_associations
  end
end
