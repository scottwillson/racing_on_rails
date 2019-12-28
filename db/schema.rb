# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_12_28_213146) do

  create_table "#Tableau_01_sid_00026E8B_4_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_00026E8B_4_Group_1a"
  end

  create_table "#Tableau_01_sid_0004055D_4_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 11
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_0004055D_4_Group_1a", length: 5
  end

  create_table "#Tableau_01_sid_000405D7_10_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_10_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_11_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_11_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_12_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_12_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_13_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_13_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_14_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_14_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_1_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 11
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_1_Group_1a", length: 5
  end

  create_table "#Tableau_01_sid_000405D7_2_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_2_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_3_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_3_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_4_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_4_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_5_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_5_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_6_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_6_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_7_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_7_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_8_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_8_Group_1a"
  end

  create_table "#Tableau_01_sid_000405D7_9_Group", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "Age (group)", limit: 21
    t.integer "age"
    t.index ["Age (group)"], name: "_tidx_#Tableau_01_sid_000405D7_9_Group_1a"
  end

  create_table "adjustments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "order_id"
    t.integer "person_id"
    t.datetime "date"
    t.decimal "amount", precision: 10, scale: 2
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aliases", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "aliasable_type", null: false
    t.integer "aliasable_id", null: false
    t.index ["aliasable_id"], name: "index_aliases_on_aliasable_id"
    t.index ["aliasable_type"], name: "index_aliases_on_aliasable_type"
    t.index ["name", "aliasable_type"], name: "index_aliases_on_name_and_aliasable_type", unique: true
    t.index ["name"], name: "index_aliases_on_name"
  end

  create_table "article_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id", default: 0
    t.integer "position", default: 0
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["updated_at"], name: "index_article_categories_on_updated_at"
  end

  create_table "articles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "heading"
    t.string "description"
    t.boolean "display"
    t.text "body"
    t.integer "position", default: 0
    t.integer "article_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["article_category_id"], name: "index_articles_on_article_category_id"
    t.index ["updated_at"], name: "index_articles_on_updated_at"
  end

  create_table "bids", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.integer "amount", null: false
    t.boolean "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "calculations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "discipline_id"
    t.bigint "event_id"
    t.bigint "source_event_id"
    t.boolean "association_sanctioned_only", default: false, null: false
    t.boolean "double_points_for_last_event", default: false, null: false
    t.string "group_by", default: "category", null: false
    t.boolean "members_only", default: false, null: false
    t.integer "minimum_events", default: 0, null: false
    t.integer "maximum_events", default: 0, null: false
    t.integer "missing_result_penalty"
    t.string "place_by", default: "points", null: false
    t.string "key"
    t.string "name", default: "New Calculation"
    t.text "points_for_place"
    t.integer "results_per_event"
    t.string "source_event_keys"
    t.boolean "specific_events", default: false, null: false
    t.boolean "team", default: false, null: false
    t.boolean "weekday_events", default: true, null: false
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "field_size_bonus", default: false, null: false
    t.string "group"
    t.index ["discipline_id"], name: "index_calculations_on_discipline_id"
    t.index ["event_id"], name: "index_calculations_on_event_id"
    t.index ["key", "year"], name: "index_calculations_on_key_and_year", unique: true
    t.index ["source_event_id"], name: "index_calculations_on_source_event_id"
  end

  create_table "calculations_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "calculation_id"
    t.bigint "category_id"
    t.integer "maximum_events"
    t.boolean "reject", default: false, null: false
    t.boolean "source_only", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calculation_id"], name: "index_calculations_categories_on_calculation_id"
    t.index ["category_id"], name: "index_calculations_categories_on_category_id"
  end

  create_table "calculations_disciplines", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "calculation_id"
    t.bigint "discipline_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calculation_id", "discipline_id"], name: "index_calc_disciplines_on_calculation_id_and_discipline_id", unique: true
    t.index ["calculation_id"], name: "index_calculations_disciplines_on_calculation_id"
    t.index ["discipline_id"], name: "index_calculations_disciplines_on_discipline_id"
  end

  create_table "calculations_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "calculation_id"
    t.bigint "event_id"
    t.float "multiplier", default: 1.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calculation_id"], name: "index_calculations_events_on_calculation_id"
    t.index ["event_id"], name: "index_calculations_events_on_event_id"
  end

  create_table "categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "position", default: 0, null: false
    t.string "name", limit: 64, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "parent_id"
    t.integer "ages_begin", default: 0
    t.integer "ages_end", default: 999
    t.string "friendly_param", null: false
    t.string "gender", default: "M", null: false
    t.integer "ability_begin", default: 0, null: false
    t.integer "ability_end", default: 999, null: false
    t.string "weight"
    t.string "equipment"
    t.index ["ability_begin"], name: "index_categories_on_ability_begin"
    t.index ["ability_end"], name: "index_categories_on_ability_end"
    t.index ["equipment"], name: "index_categories_on_equipment"
    t.index ["friendly_param"], name: "index_categories_on_friendly_param"
    t.index ["name"], name: "categories_name_index", unique: true
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["updated_at"], name: "index_categories_on_updated_at"
    t.index ["weight"], name: "index_categories_on_weight"
  end

  create_table "ckeditor_assets", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "competition_event_memberships", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "competition_id", null: false
    t.integer "event_id", null: false
    t.float "points_factor", default: 1.0
    t.string "notes"
    t.index ["competition_id"], name: "index_competition_event_memberships_on_competition_id"
    t.index ["event_id"], name: "index_competition_event_memberships_on_event_id"
  end

  create_table "discipline_aliases", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "discipline_id", default: 0, null: false
    t.string "alias", limit: 64, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["alias"], name: "idx_alias"
    t.index ["discipline_id"], name: "index_discipline_aliases_on_discipline_id"
  end

  create_table "discipline_bar_categories", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "category_id", default: 0, null: false
    t.integer "discipline_id", default: 0, null: false
    t.index ["category_id", "discipline_id"], name: "discipline_bar_categories_category_id_index", unique: true
    t.index ["discipline_id"], name: "index_discipline_bar_categories_on_discipline_id"
  end

  create_table "disciplines", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, default: "", null: false
    t.boolean "bar"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "numbers", default: false
    t.index ["name"], name: "index_disciplines_on_name", unique: true
  end

  create_table "discount_codes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "name"
    t.string "code", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "amount", precision: 10, scale: 2
    t.integer "quantity", default: 1, null: false
    t.integer "used_count", default: 0, null: false
    t.integer "created_by_id"
    t.string "created_by_type"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.string "created_by_name"
    t.string "updated_by_name"
    t.index ["created_by_id"], name: "index_discount_codes_on_created_by_id"
    t.index ["event_id"], name: "event_id"
    t.index ["updated_by_id"], name: "index_discount_codes_on_updated_by_id"
  end

  create_table "duplicates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "new_attributes"
  end

  create_table "duplicates_people", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "duplicate_id"
    t.index ["duplicate_id"], name: "index_duplicates_racers_on_duplicate_id"
    t.index ["person_id", "duplicate_id"], name: "index_duplicates_racers_on_racer_id_and_duplicate_id", unique: true
    t.index ["person_id"], name: "index_duplicates_racers_on_racer_id"
  end

  create_table "editor_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "editor_id", null: false
    t.datetime "expires_at", null: false
    t.string "token", null: false
    t.string "email", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["editor_id", "person_id"], name: "index_editor_requests_on_editor_id_and_person_id", unique: true
    t.index ["editor_id"], name: "index_editor_requests_on_editor_id"
    t.index ["expires_at"], name: "index_editor_requests_on_expires_at"
    t.index ["person_id"], name: "index_editor_requests_on_person_id"
    t.index ["token"], name: "index_editor_requests_on_token"
  end

  create_table "editors_events", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "editor_id", null: false
    t.index ["editor_id"], name: "index_editors_events_on_editor_id"
    t.index ["event_id"], name: "index_editors_events_on_event_id"
  end

  create_table "event_team_memberships", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_team_id", null: false
    t.integer "person_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_team_id", "person_id"], name: "index_event_team_memberships_on_event_team_id_and_person_id", unique: true
    t.index ["event_team_id"], name: "index_event_team_memberships_on_event_team_id"
    t.index ["person_id"], name: "index_event_team_memberships_on_person_id"
  end

  create_table "event_teams", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "team_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id", "team_id"], name: "index_event_teams_on_event_id_and_team_id", unique: true
    t.index ["event_id"], name: "index_event_teams_on_event_id"
    t.index ["team_id"], name: "index_event_teams_on_team_id"
  end

  create_table "events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "parent_id"
    t.string "city", limit: 128
    t.date "date"
    t.string "discipline", limit: 32
    t.string "flyer"
    t.string "name"
    t.text "notes"
    t.string "sanctioned_by"
    t.string "state", limit: 64
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "flyer_approved", default: false, null: false
    t.boolean "cancelled", default: false
    t.integer "number_issuer_id"
    t.string "first_aid_provider"
    t.float "pre_event_fees"
    t.float "post_event_fees"
    t.float "flyer_ad_fee"
    t.string "prize_list"
    t.integer "velodrome_id"
    t.string "time"
    t.boolean "instructional", default: false
    t.boolean "practice", default: false
    t.boolean "atra_points_series", default: false, null: false
    t.integer "bar_points", null: false
    t.boolean "ironman", null: false
    t.boolean "auto_combined_results", default: true, null: false
    t.integer "team_id"
    t.string "sanctioning_org_event_id", limit: 16
    t.integer "promoter_id"
    t.string "phone"
    t.string "email"
    t.decimal "price", precision: 10, scale: 2
    t.boolean "postponed", default: false, null: false
    t.string "chief_referee"
    t.boolean "registration", default: false, null: false
    t.boolean "beginner_friendly", default: false, null: false
    t.boolean "promoter_pays_registration_fee", default: false, null: false
    t.boolean "membership_required", default: false, null: false
    t.datetime "registration_ends_at"
    t.boolean "override_registration_ends_at", default: false, null: false
    t.decimal "all_events_discount", precision: 10, scale: 2
    t.decimal "additional_race_price", precision: 10, scale: 2
    t.string "website"
    t.string "registration_link", limit: 1024
    t.string "custom_suggestion"
    t.integer "field_limit"
    t.text "refund_policy"
    t.boolean "refunds", default: true, null: false
    t.integer "region_id"
    t.date "end_date", null: false
    t.boolean "registration_public", default: true, null: false
    t.decimal "junior_price", precision: 10, scale: 2
    t.boolean "suggest_membership", default: true, null: false
    t.string "slug"
    t.integer "year", null: false
    t.integer "created_by_id"
    t.string "created_by_type"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.string "created_by_name"
    t.string "updated_by_name"
    t.datetime "registration_start_at"
    t.index ["bar_points"], name: "index_events_on_bar_points"
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["date"], name: "index_events_on_date"
    t.index ["discipline"], name: "idx_disciplined"
    t.index ["number_issuer_id"], name: "events_number_issuer_id_index"
    t.index ["parent_id"], name: "index_events_on_parent_id"
    t.index ["promoter_id"], name: "index_events_on_promoter_id"
    t.index ["region_id"], name: "index_events_on_region_id"
    t.index ["sanctioned_by"], name: "index_events_on_sanctioned_by"
    t.index ["slug"], name: "index_events_on_slug"
    t.index ["type"], name: "idx_type"
    t.index ["type"], name: "index_events_on_type"
    t.index ["updated_at"], name: "index_events_on_updated_at"
    t.index ["updated_by_id"], name: "index_events_on_updated_by_id"
    t.index ["velodrome_id"], name: "velodrome_id"
    t.index ["year", "slug"], name: "index_events_on_year_and_slug"
    t.index ["year"], name: "index_events_on_year"
  end

  create_table "homes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "photo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "weeks_of_recent_results", default: 2, null: false
    t.integer "weeks_of_upcoming_events", default: 2, null: false
    t.index ["updated_at"], name: "index_homes_on_updated_at"
  end

  create_table "import_files", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_id"
    t.integer "race_id"
    t.decimal "amount", precision: 10, scale: 2
    t.string "string_value"
    t.boolean "boolean_value"
    t.string "type", default: "LineItem", null: false
    t.boolean "promoter_pays_registration_fee", default: false, null: false
    t.decimal "purchase_price", precision: 10, scale: 2
    t.integer "person_id"
    t.integer "year"
    t.integer "discount_code_id"
    t.integer "line_item_id"
    t.integer "product_id"
    t.integer "product_variant_id"
    t.string "status", default: "new", null: false
    t.datetime "effective_purchased_at"
    t.integer "additional_product_variant_id"
    t.integer "purchased_discount_code_id"
    t.integer "quantity", default: 1, null: false
    t.index ["additional_product_variant_id"], name: "index_line_items_on_additional_product_variant_id"
    t.index ["discount_code_id"], name: "index_line_items_on_discount_code_id"
    t.index ["event_id"], name: "index_line_items_on_event_id"
    t.index ["line_item_id"], name: "index_line_items_on_line_item_id"
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["person_id"], name: "index_line_items_on_person_id"
    t.index ["product_id"], name: "index_line_items_on_product_id"
    t.index ["product_variant_id"], name: "index_line_items_on_product_variant_id"
    t.index ["purchased_discount_code_id"], name: "index_line_items_on_purchased_discount_code_id"
    t.index ["race_id"], name: "index_line_items_on_race_id"
    t.index ["status"], name: "index_line_items_on_status"
    t.index ["type"], name: "index_line_items_on_type"
  end

  create_table "mailing_lists", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "friendly_name", default: "", null: false
    t.string "subject_line_prefix", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
    t.boolean "public", default: true, null: false
    t.index ["name"], name: "index_mailing_lists_on_name"
    t.index ["updated_at"], name: "index_mailing_lists_on_updated_at"
  end

  create_table "names", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "nameable_id", null: false
    t.string "name", null: false
    t.integer "year", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "nameable_type"
    t.string "first_name"
    t.string "last_name"
    t.index ["name"], name: "index_names_on_name"
    t.index ["nameable_id"], name: "team_id"
    t.index ["nameable_type"], name: "index_names_on_nameable_type"
    t.index ["year"], name: "index_names_on_year"
  end

  create_table "non_member_results", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.boolean "visible", default: true
    t.integer "person_id"
    t.integer "size", default: 0
    t.date "recent_result_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "non_member_results_people", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "non_member_result_id"
    t.integer "person_id"
  end

  create_table "number_issuers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "number_issuers_name_index", unique: true
  end

  create_table "offline_single_event_licenses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "event_id"
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_people", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "person_id"
    t.integer "order_id"
    t.boolean "owner", default: false, null: false
    t.boolean "membership_card", default: false, null: false
    t.date "date_of_birth"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country_code", limit: 2, default: "US"
    t.boolean "membership_address_is_billing_address", default: true, null: false
    t.string "billing_first_name"
    t.string "billing_last_name"
    t.string "billing_street"
    t.string "billing_city"
    t.string "billing_state"
    t.string "billing_zip"
    t.string "billing_country_code", limit: 2, default: "US"
    t.date "card_expires_on"
    t.string "card_brand"
    t.string "ccx_category"
    t.string "dh_category"
    t.string "email"
    t.string "home_phone"
    t.string "first_name"
    t.string "gender"
    t.string "last_name"
    t.string "mtb_category"
    t.string "occupation"
    t.boolean "official_interest", default: false, null: false
    t.boolean "race_promotion_interest", default: false, null: false
    t.boolean "team_interest", default: false, null: false
    t.boolean "volunteer_interest", default: false, null: false
    t.boolean "wants_mail", default: false, null: false
    t.boolean "wants_email", default: false, null: false
    t.string "road_category"
    t.string "team_name"
    t.string "track_category"
    t.string "emergency_contact"
    t.string "emergency_contact_phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "work_phone"
    t.string "cell_fax"
    t.boolean "velodrome_committee_interest", default: false, null: false
    t.index ["order_id"], name: "index_order_people_on_order_id"
    t.index ["person_id"], name: "index_order_people_on_person_id"
  end

  create_table "orders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.decimal "purchase_price", precision: 10, scale: 2
    t.string "notes", limit: 2000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", default: "new", null: false
    t.datetime "purchase_time"
    t.string "ip_address"
    t.boolean "waiver_accepted"
    t.string "error_message", limit: 2048
    t.string "previous_status"
    t.boolean "suggest", default: true
    t.decimal "old_purchase_fees", precision: 10, scale: 2
    t.string "gateway"
    t.index ["gateway"], name: "index_orders_on_gateway"
    t.index ["purchase_time"], name: "index_orders_on_purchase_time"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["updated_at"], name: "index_orders_on_updated_at"
  end

  create_table "pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "parent_id"
    t.text "body", null: false
    t.string "path", default: "", null: false
    t.string "slug", default: "", null: false
    t.string "title", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by_paper_trail_id"
    t.string "created_by_paper_trail_type"
    t.integer "updated_by_paper_trail_id"
    t.string "updated_by_paper_trail_type"
    t.index ["created_by_paper_trail_id"], name: "index_pages_on_created_by_paper_trail_id"
    t.index ["parent_id"], name: "parent_id"
    t.index ["path"], name: "index_pages_on_path", unique: true
    t.index ["slug"], name: "index_pages_on_slug"
    t.index ["updated_at"], name: "index_pages_on_updated_at"
    t.index ["updated_by_paper_trail_id"], name: "index_pages_on_updated_by_paper_trail_id"
  end

  create_table "payment_gateway_transactions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "order_id"
    t.string "action"
    t.integer "amount"
    t.boolean "success"
    t.string "authorization"
    t.text "message"
    t.text "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "line_item_id"
    t.index ["created_at"], name: "index_order_transactions_on_created_at"
    t.index ["line_item_id"], name: "index_payment_gateway_transactions_on_line_item_id"
    t.index ["order_id"], name: "index_order_transactions_on_order_id"
  end

  create_table "people", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "first_name", limit: 64
    t.string "last_name"
    t.string "city", limit: 128
    t.date "date_of_birth"
    t.string "license"
    t.text "notes"
    t.string "state", limit: 64
    t.integer "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "cell_fax"
    t.string "ccx_category"
    t.string "dh_category"
    t.string "email"
    t.string "gender", limit: 2
    t.string "home_phone"
    t.string "mtb_category"
    t.date "member_from"
    t.string "occupation"
    t.string "road_category"
    t.string "street"
    t.string "track_category"
    t.string "work_phone"
    t.string "zip"
    t.date "member_to"
    t.boolean "print_card", default: false
    t.boolean "ccx_only", default: false, null: false
    t.string "bmx_category"
    t.boolean "wants_email", default: false, null: false
    t.boolean "wants_mail", default: false, null: false
    t.boolean "volunteer_interest", default: false, null: false
    t.boolean "official_interest", default: false, null: false
    t.boolean "race_promotion_interest", default: false, null: false
    t.boolean "team_interest", default: false, null: false
    t.date "member_usac_to"
    t.string "status"
    t.string "crypted_password"
    t.string "password_salt"
    t.string "persistence_token"
    t.string "single_access_token"
    t.string "perishable_token"
    t.integer "login_count", default: 0, null: false
    t.integer "failed_login_count", default: 0, null: false
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string "current_login_ip"
    t.string "last_login_ip"
    t.string "login", limit: 100
    t.date "license_expiration_date"
    t.string "club_name"
    t.string "ncca_club_name"
    t.string "billing_first_name"
    t.string "billing_last_name"
    t.string "billing_street"
    t.string "billing_city"
    t.string "billing_state"
    t.string "billing_zip"
    t.string "billing_country_code", limit: 2, default: "US"
    t.string "card_brand"
    t.date "card_expires_on"
    t.boolean "membership_address_is_billing_address", default: true, null: false
    t.string "license_type"
    t.string "country_code", limit: 2, default: "US"
    t.string "emergency_contact"
    t.string "emergency_contact_phone"
    t.datetime "card_printed_at"
    t.boolean "membership_card", default: false, null: false
    t.boolean "official", default: false, null: false
    t.integer "non_member_result_id"
    t.string "name", default: "", null: false
    t.boolean "other_people_with_same_name", default: false, null: false
    t.boolean "administrator", default: false, null: false
    t.boolean "velodrome_committee_interest", default: false, null: false
    t.integer "created_by_id"
    t.string "created_by_type"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.string "created_by_name"
    t.string "updated_by_name"
    t.index ["created_by_id"], name: "index_people_on_created_by_id"
    t.index ["crypted_password"], name: "index_people_on_crypted_password"
    t.index ["email"], name: "index_people_on_email"
    t.index ["first_name"], name: "idx_first_name"
    t.index ["last_name"], name: "idx_last_name"
    t.index ["license"], name: "index_people_on_license"
    t.index ["login"], name: "index_people_on_login"
    t.index ["member_from"], name: "index_racers_on_member_from"
    t.index ["member_to"], name: "index_racers_on_member_to"
    t.index ["name"], name: "index_people_on_name"
    t.index ["non_member_result_id"], name: "index_people_on_non_member_result_id"
    t.index ["perishable_token"], name: "index_people_on_perishable_token"
    t.index ["persistence_token"], name: "index_people_on_persistence_token"
    t.index ["print_card"], name: "index_people_on_print_card"
    t.index ["single_access_token"], name: "index_people_on_single_access_token"
    t.index ["team_id"], name: "index_people_on_team_id"
    t.index ["updated_at"], name: "index_people_on_updated_at"
    t.index ["updated_by_id"], name: "index_people_on_updated_by_id"
  end

  create_table "people_people", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "editor_id", null: false
    t.index ["editor_id", "person_id"], name: "index_people_people_on_editor_id_and_person_id", unique: true
    t.index ["editor_id"], name: "index_people_people_on_editor_id"
    t.index ["person_id"], name: "index_people_people_on_person_id"
  end

  create_table "photos", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "caption"
    t.string "title"
    t.string "image"
    t.integer "height"
    t.integer "width"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "link"
    t.index ["updated_at"], name: "index_photos_on_updated_at"
  end

  create_table "posts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "date", null: false
    t.string "subject", default: "", null: false
    t.string "topica_message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "mailing_list_id", default: 0, null: false
    t.integer "position"
    t.string "from_name"
    t.string "from_email"
    t.datetime "last_reply_at"
    t.string "last_reply_from_name"
    t.integer "original_id"
    t.integer "replies_count", default: 0, null: false
    t.index ["date", "mailing_list_id"], name: "idx_date_list"
    t.index ["date"], name: "index_posts_on_date"
    t.index ["last_reply_at"], name: "index_posts_on_last_reply_at"
    t.index ["mailing_list_id"], name: "idx_mailing_list_id"
    t.index ["original_id"], name: "index_posts_on_original_id"
    t.index ["position"], name: "index_posts_on_position"
    t.index ["subject"], name: "idx_subject"
    t.index ["topica_message_id"], name: "idx_topica_message_id", unique: true
    t.index ["updated_at"], name: "index_posts_on_updated_at"
  end

  create_table "product_variants", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "price", precision: 10, scale: 2
    t.integer "position", default: 0, null: false
    t.integer "inventory"
    t.boolean "default", default: false, null: false
    t.boolean "additional", default: false, null: false
    t.integer "quantity", default: 1, null: false
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.decimal "price", precision: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_id"
    t.boolean "notify_racing_association", default: false, null: false
    t.integer "inventory"
    t.boolean "seller_pays_fee", default: false, null: false
    t.string "type"
    t.boolean "suggest", default: false, null: false
    t.string "image_url"
    t.boolean "dependent", default: false, null: false
    t.integer "seller_id"
    t.boolean "has_amount", default: false
    t.boolean "donation", default: false
    t.boolean "unique", default: false, null: false
    t.string "email"
    t.boolean "concussion_waver_required", default: false
    t.boolean "quantity", default: false, null: false
    t.integer "default_quantity", default: 1, null: false
    t.boolean "team_name", default: false, null: false
    t.boolean "string_value", default: false
    t.string "string_value_placeholder"
    t.index ["event_id"], name: "index_products_on_event_id"
    t.index ["seller_id"], name: "index_products_on_seller_id"
    t.index ["type"], name: "index_products_on_type"
  end

  create_table "race_numbers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id", default: 0, null: false
    t.integer "discipline_id", default: 0, null: false
    t.integer "number_issuer_id", default: 0, null: false
    t.string "value", default: "", null: false
    t.integer "year", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by_id"
    t.string "created_by_type"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.string "created_by_name"
    t.string "updated_by_name"
    t.index ["created_by_id"], name: "index_race_numbers_on_created_by_id"
    t.index ["discipline_id"], name: "discipline_id"
    t.index ["number_issuer_id"], name: "number_issuer_id"
    t.index ["person_id"], name: "racer_id"
    t.index ["updated_by_id"], name: "index_race_numbers_on_updated_by_id"
    t.index ["value"], name: "race_numbers_value_index"
    t.index ["year"], name: "index_race_numbers_on_year"
  end

  create_table "races", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "city", limit: 128
    t.decimal "distance", precision: 10, scale: 2
    t.string "state", limit: 64
    t.integer "field_size"
    t.integer "laps"
    t.float "time"
    t.integer "finishers"
    t.string "notes", default: ""
    t.string "sanctioned_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "result_columns"
    t.integer "bar_points"
    t.integer "event_id", null: false
    t.decimal "custom_price", precision: 10, scale: 2
    t.text "custom_columns"
    t.boolean "full", default: false, null: false
    t.integer "field_limit"
    t.boolean "additional_race_only", default: false, null: false
    t.boolean "visible", default: true
    t.integer "split_from_id"
    t.integer "created_by_id"
    t.string "created_by_type"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.string "created_by_name"
    t.string "updated_by_name"
    t.boolean "rejected"
    t.string "rejection_reason"
    t.index ["bar_points"], name: "index_races_on_bar_points"
    t.index ["category_id"], name: "index_races_on_category_id"
    t.index ["created_by_id"], name: "index_races_on_created_by_id"
    t.index ["event_id"], name: "index_races_on_event_id"
    t.index ["updated_at"], name: "index_races_on_updated_at"
    t.index ["updated_by_id"], name: "index_races_on_updated_by_id"
  end

  create_table "racing_associations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.boolean "add_members_from_results", default: true, null: false
    t.boolean "always_insert_table_headers", default: true, null: false
    t.boolean "award_cat4_participation_points", default: true, null: false
    t.boolean "bmx_numbers", default: false, null: false
    t.boolean "cx_memberships", default: false, null: false
    t.boolean "eager_match_on_license", default: false, null: false
    t.boolean "flyers_in_new_window", default: false, null: false
    t.boolean "gender_specific_numbers", default: false, null: false
    t.boolean "include_multiday_events_on_schedule", default: false, null: false
    t.boolean "show_all_teams_on_public_page", default: false, null: false
    t.boolean "show_calendar_view", default: true, null: false
    t.boolean "show_events_velodrome", default: true, null: false
    t.boolean "show_license", default: true, null: false
    t.boolean "show_only_association_sanctioned_races_on_calendar", default: true, null: false
    t.boolean "show_practices_on_calendar", default: false, null: false
    t.boolean "ssl", default: false, null: false
    t.boolean "usac_results_format", default: false, null: false
    t.integer "cat4_womens_race_series_category_id"
    t.integer "masters_age", default: 35, null: false
    t.integer "rental_numbers_end"
    t.integer "rental_numbers_start"
    t.string "cat4_womens_race_series_points"
    t.string "administrator_tabs"
    t.string "competitions"
    t.string "country_code", default: "US", null: false
    t.string "default_discipline", default: "Road", null: false
    t.string "default_sanctioned_by"
    t.string "email", default: "scott.willson@gmail.com", null: false
    t.string "exempt_team_categories", default: "0", null: false
    t.string "membership_email"
    t.string "name", default: "Cascadia Bicycle Racing Association", null: false
    t.string "rails_host", default: "localhost:3000"
    t.string "sanctioning_organizations"
    t.string "short_name", default: "CBRA", null: false
    t.string "show_events_sanctioning_org_event_id", default: "0", null: false
    t.string "state", default: "OR", null: false
    t.string "static_host", default: "localhost", null: false
    t.string "usac_region", default: "North West", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "cat4_womens_race_series_end_date"
    t.boolean "unregistered_teams_in_results", default: true, null: false
    t.date "next_year_start_at"
    t.boolean "mobile_site", default: false, null: false
    t.date "cat4_womens_race_series_start_date"
    t.boolean "filter_schedule_by_sanctioning_organization", default: false, null: false
    t.string "result_questions_url"
    t.boolean "filter_schedule_by_region", default: false, null: false
    t.string "default_region_id"
    t.boolean "allow_iframes", default: false
    t.string "payment_gateway_name", default: "elavon"
  end

  create_table "refunds", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "line_item_id", null: false
    t.integer "created_by_id"
    t.string "created_by_type"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.string "created_by_name"
    t.string "updated_by_name"
    t.index ["created_by_id"], name: "index_refunds_on_created_by_id"
    t.index ["line_item_id"], name: "index_refunds_on_line_item_id"
    t.index ["updated_by_id"], name: "index_refunds_on_updated_by_id"
  end

  create_table "regions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "friendly_param", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friendly_param"], name: "index_regions_on_friendly_param", unique: true
    t.index ["name"], name: "index_regions_on_name", unique: true
  end

  create_table "result_sources", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "calculated_result_id", null: false
    t.decimal "points", precision: 10, default: "0", null: false
    t.string "rejection_reason"
    t.integer "source_result_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "rejected", default: false, null: false
    t.index ["calculated_result_id", "source_result_id"], name: "calculated_result_id_source_result_id"
    t.index ["source_result_id"], name: "fk_rails_6213531152"
  end

  create_table "results", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "category_id"
    t.integer "person_id"
    t.integer "race_id", null: false
    t.integer "team_id"
    t.integer "age"
    t.string "city", limit: 128
    t.datetime "date_of_birth"
    t.boolean "is_series"
    t.string "license", limit: 64, default: ""
    t.string "notes"
    t.string "number", limit: 16, default: ""
    t.string "place", limit: 8, default: "", null: false
    t.integer "place_in_category", default: 0
    t.float "points", default: 0.0
    t.float "points_from_place", default: 0.0
    t.float "points_bonus_penalty", default: 0.0
    t.float "points_total", default: 0.0
    t.string "state", limit: 64
    t.string "status", limit: 3
    t.float "time", limit: 53
    t.float "time_bonus_penalty", limit: 53
    t.float "time_gap_to_leader", limit: 53
    t.float "time_gap_to_previous", limit: 53
    t.float "time_gap_to_winner", limit: 53
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "time_total", limit: 53
    t.integer "laps"
    t.string "members_only_place", limit: 8
    t.integer "points_bonus", default: 0, null: false
    t.integer "points_penalty", default: 0, null: false
    t.boolean "preliminary"
    t.boolean "bar", default: true
    t.string "gender", limit: 8
    t.string "category_class", limit: 16
    t.string "age_group", limit: 16
    t.text "custom_attributes"
    t.boolean "competition_result", null: false
    t.boolean "team_competition_result", null: false
    t.string "category_name"
    t.string "event_date_range_s", null: false
    t.date "date", null: false
    t.date "event_end_date", null: false
    t.integer "event_id", null: false
    t.string "event_full_name", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "name"
    t.string "race_name", null: false
    t.string "race_full_name", null: false
    t.string "team_name"
    t.integer "year", null: false
    t.integer "non_member_result_id"
    t.boolean "single_event_license", default: false
    t.boolean "team_member", default: false, null: false
    t.decimal "distance", precision: 10, scale: 2
    t.boolean "rejected", default: false, null: false
    t.string "rejection_reason"
    t.integer "numeric_place", default: 999999, null: false
    t.index ["category_id"], name: "index_results_on_category_id"
    t.index ["event_id"], name: "index_results_on_event_id"
    t.index ["members_only_place"], name: "index_results_on_members_only_place"
    t.index ["non_member_result_id"], name: "index_results_on_non_member_result_id"
    t.index ["person_id"], name: "idx_racer_id"
    t.index ["place"], name: "index_results_on_place"
    t.index ["race_id"], name: "idx_race_id"
    t.index ["team_id"], name: "index_results_on_team_id"
    t.index ["updated_at"], name: "index_results_on_updated_at"
    t.index ["year"], name: "index_results_on_year"
  end

  create_table "scores", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "competition_result_id"
    t.integer "source_result_id"
    t.float "points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "date"
    t.string "description"
    t.string "event_name"
    t.string "notes"
    t.index ["competition_result_id"], name: "scores_competition_result_id_index"
    t.index ["source_result_id"], name: "scores_source_result_id_index"
  end

  create_table "teams", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "city", limit: 128
    t.string "state", limit: 64
    t.string "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "member", default: false
    t.string "website"
    t.string "sponsors", limit: 1000
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.boolean "show_on_public_page", default: true
    t.integer "created_by_id"
    t.string "created_by_type"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.string "created_by_name"
    t.string "updated_by_name"
    t.index ["created_by_id"], name: "index_teams_on_created_by_id"
    t.index ["name"], name: "index_teams_on_name"
    t.index ["updated_at"], name: "index_teams_on_updated_at"
    t.index ["updated_by_id"], name: "index_teams_on_updated_by_id"
  end

  create_table "update_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "order_person_id", null: false
    t.datetime "expires_at", null: false
    t.string "token", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["expires_at"], name: "index_update_requests_on_expires_at"
    t.index ["order_person_id"], name: "index_update_requests_on_order_person_id", unique: true
    t.index ["token"], name: "index_update_requests_on_token"
  end

  create_table "velodromes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_velodromes_on_name"
  end

  create_table "versions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 4294967295
    t.text "object_changes", limit: 4294967295
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "categories", "categories", column: "parent_id", on_delete: :cascade
  add_foreign_key "competition_event_memberships", "events", column: "competition_id", name: "competition_event_memberships_competitions_id_fk", on_delete: :cascade
  add_foreign_key "competition_event_memberships", "events", name: "competition_event_memberships_events_id_fk", on_delete: :cascade
  add_foreign_key "discipline_aliases", "disciplines", on_delete: :cascade
  add_foreign_key "discipline_bar_categories", "categories", name: "discipline_bar_categories_categories_id_fk", on_delete: :cascade
  add_foreign_key "discipline_bar_categories", "disciplines", on_delete: :cascade
  add_foreign_key "discount_codes", "events", name: "discount_codes_ibfk_1"
  add_foreign_key "duplicates_people", "duplicates", name: "duplicates_racers_duplicates_id_fk", on_delete: :cascade
  add_foreign_key "duplicates_people", "people", name: "duplicates_people_person_id", on_delete: :cascade
  add_foreign_key "editor_requests", "people", column: "editor_id", name: "editor_requests_ibfk_1", on_delete: :cascade
  add_foreign_key "editor_requests", "people", name: "editor_requests_ibfk_2", on_delete: :cascade
  add_foreign_key "events", "events", column: "parent_id", on_delete: :cascade
  add_foreign_key "events", "number_issuers", name: "events_number_issuers_id_fk"
  add_foreign_key "events", "people", column: "promoter_id", name: "events_promoter_id", on_delete: :nullify
  add_foreign_key "events", "velodromes", name: "events_velodrome_id_fk"
  add_foreign_key "order_people", "orders", name: "order_people_ibfk_2", on_delete: :cascade
  add_foreign_key "order_people", "people", name: "order_people_ibfk_1", on_delete: :cascade
  add_foreign_key "pages", "pages", column: "parent_id", name: "pages_parent_id_fk"
  add_foreign_key "people", "teams"
  add_foreign_key "people_people", "people", column: "editor_id", name: "people_people_ibfk_1", on_delete: :cascade
  add_foreign_key "people_people", "people", name: "people_people_ibfk_2", on_delete: :cascade
  add_foreign_key "posts", "mailing_lists", name: "posts_mailing_list_id_fk"
  add_foreign_key "race_numbers", "disciplines", name: "race_numbers_discipline_id_fk"
  add_foreign_key "race_numbers", "number_issuers", name: "race_numbers_number_issuer_id_fk"
  add_foreign_key "race_numbers", "people", name: "race_numbers_person_id", on_delete: :cascade
  add_foreign_key "races", "categories"
  add_foreign_key "races", "events", name: "races_event_id_fk", on_delete: :cascade
  add_foreign_key "result_sources", "results", column: "calculated_result_id", on_delete: :cascade
  add_foreign_key "result_sources", "results", column: "source_result_id", on_delete: :cascade
  add_foreign_key "results", "categories"
  add_foreign_key "results", "people", name: "results_person_id"
  add_foreign_key "results", "races", name: "results_race_id_fk", on_delete: :cascade
  add_foreign_key "results", "teams"
  add_foreign_key "scores", "results", column: "competition_result_id", name: "scores_competition_result_id_fk", on_delete: :cascade
  add_foreign_key "scores", "results", column: "source_result_id", name: "scores_source_result_id_fk", on_delete: :cascade
  add_foreign_key "update_requests", "order_people", name: "update_requests_ibfk_1", on_delete: :cascade
end
