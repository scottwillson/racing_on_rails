# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081102001855) do

  create_table "aliases", :force => true do |t|
    t.string   "alias"
    t.string   "name"
    t.integer  "person_id"
    t.integer  "team_id"
    t.integer  "lock_version", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "aliases", ["name"], :name => "idx_name", :unique => true
  add_index "aliases", ["alias"], :name => "idx_id"
  add_index "aliases", ["person_id"], :name => "idx_person_id"
  add_index "aliases", ["team_id"], :name => "idx_team_id"

  create_table "bids", :force => true do |t|
    t.string   "name",         :default => "", :null => false
    t.string   "email",        :default => "", :null => false
    t.string   "phone",        :default => "", :null => false
    t.integer  "amount",       :default => 0,  :null => false
    t.boolean  "approved"
    t.integer  "lock_version", :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.integer  "position",                     :default => 0,   :null => false
    t.string   "name",           :limit => 64, :default => "",  :null => false
    t.integer  "lock_version",                 :default => 0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "ages_begin",                   :default => 0
    t.integer  "ages_end",                     :default => 999
    t.string   "friendly_param",               :default => "",  :null => false
  end

  add_index "categories", ["name"], :name => "categories_name_index", :unique => true
  add_index "categories", ["parent_id"], :name => "parent_id"
  add_index "categories", ["friendly_param"], :name => "index_categories_on_friendly_param"

  create_table "discipline_aliases", :id => false, :force => true do |t|
    t.integer  "discipline_id",               :default => 0,  :null => false
    t.string   "alias",         :limit => 64, :default => "", :null => false
    t.integer  "lock_version",                :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discipline_aliases", ["alias"], :name => "idx_alias"
  add_index "discipline_aliases", ["discipline_id"], :name => "idx_discipline_id"

  create_table "discipline_bar_categories", :id => false, :force => true do |t|
    t.integer  "category_id",   :default => 0, :null => false
    t.integer  "discipline_id", :default => 0, :null => false
    t.integer  "lock_version",  :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discipline_bar_categories", ["category_id", "discipline_id"], :name => "discipline_bar_categories_category_id_index", :unique => true
  add_index "discipline_bar_categories", ["category_id"], :name => "idx_category_id"
  add_index "discipline_bar_categories", ["discipline_id"], :name => "idx_discipline_id"

  create_table "disciplines", :force => true do |t|
    t.string   "name",         :limit => 64, :default => "",    :null => false
    t.boolean  "bar"
    t.integer  "lock_version",               :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "numbers",                    :default => false
  end

  create_table "duplicates", :force => true do |t|
    t.text "new_attributes"
  end

  create_table "duplicates_people", :id => false, :force => true do |t|
    t.integer "person_id"
    t.integer "duplicate_id"
  end

  add_index "duplicates_people", ["person_id", "duplicate_id"], :name => "index_duplicates_people_on_person_id_and_duplicate_id", :unique => true
  add_index "duplicates_people", ["person_id"], :name => "index_duplicates_people_on_person_id"
  add_index "duplicates_people", ["duplicate_id"], :name => "index_duplicates_people_on_duplicate_id"

  create_table "events", :force => true do |t|
    t.integer  "promoter_id"
    t.integer  "parent_id"
    t.string   "city",                       :limit => 128
    t.date     "date"
    t.string   "discipline",                 :limit => 32
    t.string   "flyer"
    t.string   "name"
    t.string   "notes",                                     :default => ""
    t.string   "sanctioned_by"
    t.string   "state",                      :limit => 64
    t.string   "type",                       :limit => 32,  :default => "",              :null => false
    t.integer  "lock_version",                              :default => 0,               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flyer_approved",                            :default => false,           :null => false
    t.boolean  "cancelled",                                 :default => false
    t.integer  "oregon_cup_id"
    t.boolean  "notification",                              :default => true
    t.integer  "number_issuer_id"
    t.string   "first_aid_provider",                        :default => "-------------"
    t.float    "pre_event_fees"
    t.float    "post_event_fees"
    t.float    "flyer_ad_fee"
    t.integer  "cat4_womens_race_series_id"
    t.string   "prize_list"
    t.integer  "velodrome_id"
    t.string   "time"
    t.boolean  "instructional",                             :default => false
    t.boolean  "practice",                                  :default => false
  end

  add_index "events", ["date"], :name => "idx_date"
  add_index "events", ["discipline"], :name => "idx_disciplined"
  add_index "events", ["parent_id"], :name => "parent_id"
  add_index "events", ["promoter_id"], :name => "idx_promoter_id"
  add_index "events", ["type"], :name => "idx_type"
  add_index "events", ["oregon_cup_id"], :name => "oregon_cup_id"
  add_index "events", ["number_issuer_id"], :name => "events_number_issuer_id_index"
  add_index "events", ["velodrome_id"], :name => "velodrome_id"

  create_table "historical_names", :force => true do |t|
    t.integer  "team_id",                     :null => false
    t.string   "name",                        :null => false
    t.integer  "year",                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0, :null => false
  end

  add_index "historical_names", ["team_id"], :name => "team_id"
  add_index "historical_names", ["name"], :name => "index_names_on_name"
  add_index "historical_names", ["year"], :name => "index_names_on_year"

  create_table "images", :force => true do |t|
    t.string   "caption"
    t.string   "html_options"
    t.string   "link"
    t.string   "name",         :default => "", :null => false
    t.string   "source",       :default => "", :null => false
    t.integer  "lock_version", :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["name"], :name => "images_name_index", :unique => true

  create_table "mailing_lists", :force => true do |t|
    t.string   "name",                :default => "", :null => false
    t.string   "friendly_name",       :default => "", :null => false
    t.string   "subject_line_prefix", :default => "", :null => false
    t.integer  "lock_version",        :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "mailing_lists", ["name"], :name => "idx_name"

  create_table "news_items", :force => true do |t|
    t.date     "date",                         :null => false
    t.string   "text",         :default => "", :null => false
    t.integer  "lock_version", :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news_items", ["date"], :name => "news_items_date_index"
  add_index "news_items", ["text"], :name => "news_items_text_index"

  create_table "number_issuers", :force => true do |t|
    t.string   "name",         :default => "", :null => false
    t.integer  "lock_version", :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "number_issuers", ["name"], :name => "number_issuers_name_index", :unique => true

  create_table "posts", :force => true do |t|
    t.text      "body",                              :null => false
    t.timestamp "date",                              :null => false
    t.string    "sender",            :default => "", :null => false
    t.string    "subject",           :default => "", :null => false
    t.string    "topica_message_id"
    t.integer   "lock_version",      :default => 0,  :null => false
    t.datetime  "created_at"
    t.datetime  "updated_at"
    t.integer   "mailing_list_id",   :default => 0,  :null => false
  end

  add_index "posts", ["topica_message_id"], :name => "idx_topica_message_id", :unique => true
  add_index "posts", ["date"], :name => "idx_date"
  add_index "posts", ["sender"], :name => "idx_sender"
  add_index "posts", ["subject"], :name => "idx_subject"
  add_index "posts", ["mailing_list_id"], :name => "idx_mailing_list_id"
  add_index "posts", ["date", "mailing_list_id"], :name => "idx_date_list"

  create_table "promoters", :force => true do |t|
    t.string   "email"
    t.string   "name",         :default => ""
    t.string   "phone"
    t.integer  "lock_version", :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promoters", ["name", "email", "phone"], :name => "promoter_info", :unique => true
  add_index "promoters", ["name"], :name => "idx_name"

  create_table "race_numbers", :force => true do |t|
    t.integer  "person_id",         :default => 0,  :null => false
    t.integer  "discipline_id",    :default => 0,  :null => false
    t.integer  "number_issuer_id", :default => 0,  :null => false
    t.string   "value",            :default => "", :null => false
    t.integer  "year",             :default => 0,  :null => false
    t.integer  "lock_version",     :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "updated_by"
  end

  add_index "race_numbers", ["person_id"], :name => "person_id"
  add_index "race_numbers", ["discipline_id"], :name => "discipline_id"
  add_index "race_numbers", ["number_issuer_id"], :name => "number_issuer_id"
  add_index "race_numbers", ["value"], :name => "race_numbers_value_index"

  create_table "people", :force => true do |t|
    t.string   "first_name",          :limit => 64
    t.string   "last_name"
    t.string   "city",                :limit => 128
    t.date     "date_of_birth"
    t.string   "license",             :limit => 64
    t.text     "notes"
    t.string   "state",               :limit => 64
    t.integer  "team_id"
    t.integer  "lock_version",                       :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cell_fax"
    t.string   "ccx_category"
    t.string   "dh_category"
    t.string   "email"
    t.string   "gender",              :limit => 2
    t.string   "home_phone"
    t.string   "mtb_category"
    t.date     "member_from"
    t.string   "occupation"
    t.string   "road_category"
    t.string   "street"
    t.string   "track_category"
    t.string   "work_phone"
    t.string   "zip"
    t.date     "member_to"
    t.boolean  "print_card",                         :default => false
    t.boolean  "print_mailing_label",                :default => false
    t.boolean  "ccx_only",                           :default => false, :null => false
    t.string   "updated_by"
    t.string   "bmx_category"
    t.boolean  "wants_email",                        :default => true,  :null => false
    t.boolean  "wants_mail",                         :default => true,  :null => false
  end

  add_index "people", ["last_name"], :name => "idx_last_name"
  add_index "people", ["first_name"], :name => "idx_first_name"
  add_index "people", ["team_id"], :name => "idx_team_id"

  create_table "races", :force => true do |t|
    t.integer  "standings_id",                  :default => 0,      :null => false
    t.integer  "category_id",                   :default => 0,      :null => false
    t.string   "city",           :limit => 128
    t.integer  "distance"
    t.string   "state",          :limit => 64
    t.integer  "field_size"
    t.integer  "laps"
    t.float    "time"
    t.integer  "finishers"
    t.string   "notes",                         :default => ""
    t.string   "sanctioned_by",                 :default => "OBRA"
    t.integer  "lock_version",                  :default => 0,      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "result_columns"
    t.integer  "bar_points"
  end

  add_index "races", ["category_id"], :name => "idx_category_id"
  add_index "races", ["standings_id"], :name => "idx_standings_id"

  create_table "results", :force => true do |t|
    t.integer  "category_id"
    t.integer  "person_id"
    t.integer  "race_id",                             :default => 0,    :null => false
    t.integer  "team_id"
    t.integer  "age"
    t.string   "city",                 :limit => 128
    t.datetime "date"
    t.datetime "date_of_birth"
    t.boolean  "is_series"
    t.string   "license",              :limit => 64,  :default => ""
    t.string   "notes"
    t.string   "number",               :limit => 16,  :default => ""
    t.string   "place",                :limit => 8,   :default => ""
    t.integer  "place_in_category",                   :default => 0
    t.float    "points",                              :default => 0.0
    t.float    "points_from_place",                   :default => 0.0
    t.float    "points_bonus_penalty",                :default => 0.0
    t.float    "points_total",                        :default => 0.0
    t.string   "state",                :limit => 64
    t.string   "status",               :limit => 3
    t.float    "time"
    t.float    "time_bonus_penalty"
    t.float    "time_gap_to_leader"
    t.float    "time_gap_to_previous"
    t.float    "time_gap_to_winner"
    t.integer  "lock_version",                        :default => 0,    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "time_total"
    t.integer  "laps"
    t.string   "members_only_place",   :limit => 8
    t.integer  "points_bonus",                        :default => 0,    :null => false
    t.integer  "points_penalty",                      :default => 0,    :null => false
    t.boolean  "preliminary"
    t.boolean  "bar",                                 :default => true
  end

  add_index "results", ["category_id"], :name => "idx_category_id"
  add_index "results", ["race_id"], :name => "idx_race_id"
  add_index "results", ["person_id"], :name => "idx_person_id"
  add_index "results", ["team_id"], :name => "idx_team_id"

  create_table "scores", :force => true do |t|
    t.integer  "competition_result_id"
    t.integer  "source_result_id"
    t.float    "points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["competition_result_id"], :name => "scores_competition_result_id_index"
  add_index "scores", ["source_result_id"], :name => "scores_source_result_id_index"

  create_table "standings", :force => true do |t|
    t.integer  "event_id",                              :default => 0,    :null => false
    t.integer  "bar_points",                            :default => 1
    t.string   "name"
    t.integer  "lock_version",                          :default => 0,    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ironman",                               :default => true
    t.integer  "position",                              :default => 0
    t.string   "discipline",              :limit => 32
    t.string   "notes",                                 :default => ""
    t.integer  "source_id"
    t.string   "type",                    :limit => 32
    t.boolean  "auto_combined_standings",               :default => true
  end

  add_index "standings", ["event_id"], :name => "event_id"
  add_index "standings", ["source_id"], :name => "source_id"

  create_table "teams", :force => true do |t|
    t.string   "name",                                :default => "",    :null => false
    t.string   "city",                :limit => 128
    t.string   "state",               :limit => 64
    t.string   "notes"
    t.integer  "lock_version",                        :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "member",                              :default => false
    t.string   "website"
    t.string   "sponsors",            :limit => 1000
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.boolean  "show_on_public_page",                 :default => false
  end

  add_index "teams", ["name"], :name => "idx_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name",         :default => "", :null => false
    t.string   "username",     :default => "", :null => false
    t.string   "password",     :default => "", :null => false
    t.integer  "lock_version", :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], :name => "idx_alias", :unique => true

  create_table "velodromes", :force => true do |t|
    t.string   "name"
    t.string   "website"
    t.integer  "lock_version", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
