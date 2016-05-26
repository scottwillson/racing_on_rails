# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160526225129) do

  create_table "adjustments", force: :cascade do |t|
    t.integer  "order_id",    limit: 4
    t.integer  "person_id",   limit: 4
    t.datetime "date"
    t.decimal  "amount",                  precision: 10, scale: 2
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aliases", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "aliasable_type", limit: 255, null: false
    t.integer  "aliasable_id",   limit: 4,   null: false
  end

  add_index "aliases", ["aliasable_id"], name: "index_aliases_on_aliasable_id", using: :btree
  add_index "aliases", ["aliasable_type"], name: "index_aliases_on_aliasable_type", using: :btree
  add_index "aliases", ["name", "aliasable_type"], name: "index_aliases_on_name_and_aliasable_type", unique: true, using: :btree
  add_index "aliases", ["name"], name: "index_aliases_on_name", using: :btree

  create_table "article_categories", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "parent_id",   limit: 4,   default: 0
    t.integer  "position",    limit: 4,   default: 0
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "article_categories", ["updated_at"], name: "index_article_categories_on_updated_at", using: :btree

  create_table "articles", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "heading",             limit: 255
    t.string   "description",         limit: 255
    t.boolean  "display"
    t.text     "body",                limit: 65535
    t.integer  "position",            limit: 4,     default: 0
    t.integer  "article_category_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles", ["article_category_id"], name: "index_articles_on_article_category_id", using: :btree
  add_index "articles", ["updated_at"], name: "index_articles_on_updated_at", using: :btree

  create_table "bids", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "email",      limit: 255, null: false
    t.string   "phone",      limit: 255, null: false
    t.integer  "amount",     limit: 4,   null: false
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.integer  "position",       limit: 4,   default: 0,   null: false
    t.string   "name",           limit: 64,  default: "",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",      limit: 4
    t.integer  "ages_begin",     limit: 4,   default: 0
    t.integer  "ages_end",       limit: 4,   default: 999
    t.string   "friendly_param", limit: 255,               null: false
    t.integer  "ability",        limit: 4,   default: 0,   null: false
    t.string   "gender",         limit: 255, default: "M", null: false
  end

  add_index "categories", ["friendly_param"], name: "index_categories_on_friendly_param", using: :btree
  add_index "categories", ["name"], name: "categories_name_index", unique: true, using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["updated_at"], name: "index_categories_on_updated_at", using: :btree

  create_table "competition_event_memberships", force: :cascade do |t|
    t.integer "competition_id", limit: 4,                 null: false
    t.integer "event_id",       limit: 4,                 null: false
    t.float   "points_factor",  limit: 24,  default: 1.0
    t.string  "notes",          limit: 255
  end

  add_index "competition_event_memberships", ["competition_id"], name: "index_competition_event_memberships_on_competition_id", using: :btree
  add_index "competition_event_memberships", ["event_id"], name: "index_competition_event_memberships_on_event_id", using: :btree

  create_table "discipline_aliases", id: false, force: :cascade do |t|
    t.integer  "discipline_id", limit: 4,  default: 0,  null: false
    t.string   "alias",         limit: 64, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discipline_aliases", ["alias"], name: "idx_alias", using: :btree
  add_index "discipline_aliases", ["discipline_id"], name: "index_discipline_aliases_on_discipline_id", using: :btree

  create_table "discipline_bar_categories", id: false, force: :cascade do |t|
    t.integer "category_id",   limit: 4, default: 0, null: false
    t.integer "discipline_id", limit: 4, default: 0, null: false
  end

  add_index "discipline_bar_categories", ["category_id", "discipline_id"], name: "discipline_bar_categories_category_id_index", unique: true, using: :btree
  add_index "discipline_bar_categories", ["discipline_id"], name: "index_discipline_bar_categories_on_discipline_id", using: :btree

  create_table "disciplines", force: :cascade do |t|
    t.string   "name",       limit: 64, default: "",    null: false
    t.boolean  "bar"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "numbers",               default: false
  end

  add_index "disciplines", ["name"], name: "index_disciplines_on_name", unique: true, using: :btree

  create_table "discount_codes", force: :cascade do |t|
    t.integer  "event_id",        limit: 4,                                        null: false
    t.string   "name",            limit: 255
    t.string   "code",            limit: 255,                                      null: false
    t.integer  "created_by_id",   limit: 4
    t.string   "created_by_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",                      precision: 10, scale: 2
    t.integer  "quantity",        limit: 4,                            default: 1, null: false
    t.integer  "used_count",      limit: 4,                            default: 0, null: false
  end

  add_index "discount_codes", ["event_id"], name: "event_id", using: :btree

  create_table "duplicates", force: :cascade do |t|
    t.text "new_attributes", limit: 65535
  end

  create_table "duplicates_people", id: false, force: :cascade do |t|
    t.integer "person_id",    limit: 4
    t.integer "duplicate_id", limit: 4
  end

  add_index "duplicates_people", ["duplicate_id"], name: "index_duplicates_racers_on_duplicate_id", using: :btree
  add_index "duplicates_people", ["person_id", "duplicate_id"], name: "index_duplicates_racers_on_racer_id_and_duplicate_id", unique: true, using: :btree
  add_index "duplicates_people", ["person_id"], name: "index_duplicates_racers_on_racer_id", using: :btree

  create_table "editor_requests", force: :cascade do |t|
    t.integer  "person_id",  limit: 4,   null: false
    t.integer  "editor_id",  limit: 4,   null: false
    t.datetime "expires_at",             null: false
    t.string   "token",      limit: 255, null: false
    t.string   "email",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "editor_requests", ["editor_id", "person_id"], name: "index_editor_requests_on_editor_id_and_person_id", unique: true, using: :btree
  add_index "editor_requests", ["editor_id"], name: "index_editor_requests_on_editor_id", using: :btree
  add_index "editor_requests", ["expires_at"], name: "index_editor_requests_on_expires_at", using: :btree
  add_index "editor_requests", ["person_id"], name: "index_editor_requests_on_person_id", using: :btree
  add_index "editor_requests", ["token"], name: "index_editor_requests_on_token", using: :btree

  create_table "editors_events", id: false, force: :cascade do |t|
    t.integer "event_id",  limit: 4, null: false
    t.integer "editor_id", limit: 4, null: false
  end

  add_index "editors_events", ["editor_id"], name: "index_editors_events_on_editor_id", using: :btree
  add_index "editors_events", ["event_id"], name: "index_editors_events_on_event_id", using: :btree

  create_table "event_team_memberships", force: :cascade do |t|
    t.integer  "event_team_id", limit: 4, null: false
    t.integer  "person_id",     limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_team_memberships", ["event_team_id", "person_id"], name: "index_event_team_memberships_on_event_team_id_and_person_id", unique: true, using: :btree
  add_index "event_team_memberships", ["event_team_id"], name: "index_event_team_memberships_on_event_team_id", using: :btree
  add_index "event_team_memberships", ["person_id"], name: "index_event_team_memberships_on_person_id", using: :btree

  create_table "event_teams", force: :cascade do |t|
    t.integer  "event_id",   limit: 4, null: false
    t.integer  "team_id",    limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_teams", ["event_id", "team_id"], name: "index_event_teams_on_event_id_and_team_id", unique: true, using: :btree
  add_index "event_teams", ["event_id"], name: "index_event_teams_on_event_id", using: :btree
  add_index "event_teams", ["team_id"], name: "index_event_teams_on_team_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "parent_id",                      limit: 4
    t.string   "city",                           limit: 128
    t.date     "date"
    t.string   "discipline",                     limit: 32
    t.string   "flyer",                          limit: 255
    t.string   "name",                           limit: 255
    t.text     "notes",                          limit: 65535
    t.string   "sanctioned_by",                  limit: 255
    t.string   "state",                          limit: 64
    t.string   "type",                           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flyer_approved",                                                        default: false, null: false
    t.boolean  "cancelled",                                                             default: false
    t.integer  "number_issuer_id",               limit: 4
    t.string   "first_aid_provider",             limit: 255
    t.float    "pre_event_fees",                 limit: 24
    t.float    "post_event_fees",                limit: 24
    t.float    "flyer_ad_fee",                   limit: 24
    t.string   "prize_list",                     limit: 255
    t.integer  "velodrome_id",                   limit: 4
    t.string   "time",                           limit: 255
    t.boolean  "instructional",                                                         default: false
    t.boolean  "practice",                                                              default: false
    t.boolean  "atra_points_series",                                                    default: false, null: false
    t.integer  "bar_points",                     limit: 4,                                              null: false
    t.boolean  "ironman",                                                                               null: false
    t.boolean  "auto_combined_results",                                                 default: true,  null: false
    t.integer  "team_id",                        limit: 4
    t.string   "sanctioning_org_event_id",       limit: 16
    t.integer  "promoter_id",                    limit: 4
    t.string   "phone",                          limit: 255
    t.string   "email",                          limit: 255
    t.decimal  "price",                                        precision: 10, scale: 2
    t.boolean  "postponed",                                                             default: false, null: false
    t.string   "chief_referee",                  limit: 255
    t.boolean  "registration",                                                          default: false, null: false
    t.boolean  "beginner_friendly",                                                     default: false, null: false
    t.boolean  "promoter_pays_registration_fee",                                        default: false, null: false
    t.boolean  "membership_required",                                                   default: false, null: false
    t.datetime "registration_ends_at"
    t.boolean  "override_registration_ends_at",                                         default: false, null: false
    t.decimal  "all_events_discount",                          precision: 10, scale: 2
    t.decimal  "additional_race_price",                        precision: 10, scale: 2
    t.string   "website",                        limit: 255
    t.string   "registration_link",              limit: 255
    t.string   "custom_suggestion",              limit: 255
    t.integer  "field_limit",                    limit: 4
    t.text     "refund_policy",                  limit: 65535
    t.boolean  "refunds",                                                               default: true,  null: false
    t.integer  "region_id",                      limit: 4
    t.date     "end_date",                                                                              null: false
    t.boolean  "registration_public",                                                   default: true,  null: false
    t.decimal  "junior_price",                                 precision: 10, scale: 2
    t.boolean  "suggest_membership",                                                    default: true,  null: false
    t.string   "slug",                           limit: 255
    t.integer  "year",                           limit: 4,                                              null: false
  end

  add_index "events", ["bar_points"], name: "index_events_on_bar_points", using: :btree
  add_index "events", ["date"], name: "index_events_on_date", using: :btree
  add_index "events", ["discipline"], name: "idx_disciplined", using: :btree
  add_index "events", ["number_issuer_id"], name: "events_number_issuer_id_index", using: :btree
  add_index "events", ["parent_id"], name: "index_events_on_parent_id", using: :btree
  add_index "events", ["promoter_id"], name: "index_events_on_promoter_id", using: :btree
  add_index "events", ["region_id"], name: "index_events_on_region_id", using: :btree
  add_index "events", ["sanctioned_by"], name: "index_events_on_sanctioned_by", using: :btree
  add_index "events", ["slug"], name: "index_events_on_slug", using: :btree
  add_index "events", ["type"], name: "idx_type", using: :btree
  add_index "events", ["type"], name: "index_events_on_type", using: :btree
  add_index "events", ["updated_at"], name: "index_events_on_updated_at", using: :btree
  add_index "events", ["velodrome_id"], name: "velodrome_id", using: :btree
  add_index "events", ["year", "slug"], name: "index_events_on_year_and_slug", using: :btree
  add_index "events", ["year"], name: "index_events_on_year", using: :btree

  create_table "homes", force: :cascade do |t|
    t.integer  "photo_id",                 limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "weeks_of_recent_results",  limit: 4, default: 2, null: false
    t.integer  "weeks_of_upcoming_events", limit: 4, default: 2, null: false
  end

  add_index "homes", ["updated_at"], name: "index_homes_on_updated_at", using: :btree

  create_table "import_files", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer  "order_id",                       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id",                       limit: 4
    t.integer  "race_id",                        limit: 4
    t.decimal  "amount",                                     precision: 10, scale: 2
    t.string   "string_value",                   limit: 255
    t.boolean  "boolean_value"
    t.string   "type",                           limit: 255,                          default: "LineItem", null: false
    t.boolean  "promoter_pays_registration_fee",                                      default: false,      null: false
    t.decimal  "purchase_price",                             precision: 10, scale: 2
    t.integer  "person_id",                      limit: 4
    t.integer  "year",                           limit: 4
    t.integer  "discount_code_id",               limit: 4
    t.integer  "line_item_id",                   limit: 4
    t.integer  "product_id",                     limit: 4
    t.integer  "product_variant_id",             limit: 4
    t.string   "status",                         limit: 255,                          default: "new",      null: false
    t.datetime "effective_purchased_at"
    t.integer  "additional_product_variant_id",  limit: 4
    t.integer  "purchased_discount_code_id",     limit: 4
    t.integer  "quantity",                       limit: 4,                            default: 1,          null: false
  end

  add_index "line_items", ["additional_product_variant_id"], name: "index_line_items_on_additional_product_variant_id", using: :btree
  add_index "line_items", ["discount_code_id"], name: "index_line_items_on_discount_code_id", using: :btree
  add_index "line_items", ["event_id"], name: "index_line_items_on_event_id", using: :btree
  add_index "line_items", ["line_item_id"], name: "index_line_items_on_line_item_id", using: :btree
  add_index "line_items", ["order_id"], name: "index_line_items_on_order_id", using: :btree
  add_index "line_items", ["person_id"], name: "index_line_items_on_person_id", using: :btree
  add_index "line_items", ["product_id"], name: "index_line_items_on_product_id", using: :btree
  add_index "line_items", ["product_variant_id"], name: "index_line_items_on_product_variant_id", using: :btree
  add_index "line_items", ["purchased_discount_code_id"], name: "index_line_items_on_purchased_discount_code_id", using: :btree
  add_index "line_items", ["race_id"], name: "index_line_items_on_race_id", using: :btree

  create_table "mailing_lists", force: :cascade do |t|
    t.string   "name",                limit: 255,   default: "",   null: false
    t.string   "friendly_name",       limit: 255,   default: "",   null: false
    t.string   "subject_line_prefix", limit: 255,   default: "",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description",         limit: 65535
    t.boolean  "public",                            default: true, null: false
  end

  add_index "mailing_lists", ["name"], name: "index_mailing_lists_on_name", using: :btree
  add_index "mailing_lists", ["updated_at"], name: "index_mailing_lists_on_updated_at", using: :btree

  create_table "names", force: :cascade do |t|
    t.integer  "nameable_id",   limit: 4,   null: false
    t.string   "name",          limit: 255, null: false
    t.integer  "year",          limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nameable_type", limit: 255
    t.string   "first_name",    limit: 255
    t.string   "last_name",     limit: 255
  end

  add_index "names", ["name"], name: "index_names_on_name", using: :btree
  add_index "names", ["nameable_id"], name: "team_id", using: :btree
  add_index "names", ["nameable_type"], name: "index_names_on_nameable_type", using: :btree
  add_index "names", ["year"], name: "index_names_on_year", using: :btree

  create_table "non_member_results", force: :cascade do |t|
    t.boolean  "visible",                    default: true
    t.integer  "person_id",        limit: 4
    t.integer  "size",             limit: 4, default: 0
    t.date     "recent_result_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "non_member_results_people", id: false, force: :cascade do |t|
    t.integer "non_member_result_id", limit: 4
    t.integer "person_id",            limit: 4
  end

  create_table "number_issuers", force: :cascade do |t|
    t.string   "name",       limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "number_issuers", ["name"], name: "number_issuers_name_index", unique: true, using: :btree

  create_table "offline_single_event_licenses", force: :cascade do |t|
    t.integer  "event_id",   limit: 4
    t.integer  "person_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_people", force: :cascade do |t|
    t.integer  "person_id",                             limit: 4
    t.integer  "order_id",                              limit: 4
    t.boolean  "owner",                                             default: false, null: false
    t.boolean  "membership_card",                                   default: false, null: false
    t.date     "date_of_birth"
    t.string   "street",                                limit: 255
    t.string   "city",                                  limit: 255
    t.string   "state",                                 limit: 255
    t.string   "zip",                                   limit: 255
    t.string   "country_code",                          limit: 2,   default: "US"
    t.boolean  "membership_address_is_billing_address",             default: true,  null: false
    t.string   "billing_first_name",                    limit: 255
    t.string   "billing_last_name",                     limit: 255
    t.string   "billing_street",                        limit: 255
    t.string   "billing_city",                          limit: 255
    t.string   "billing_state",                         limit: 255
    t.string   "billing_zip",                           limit: 255
    t.string   "billing_country_code",                  limit: 2,   default: "US"
    t.date     "card_expires_on"
    t.string   "card_brand",                            limit: 255
    t.string   "ccx_category",                          limit: 255
    t.string   "dh_category",                           limit: 255
    t.string   "email",                                 limit: 255
    t.string   "home_phone",                            limit: 255
    t.string   "first_name",                            limit: 255
    t.string   "gender",                                limit: 255
    t.string   "last_name",                             limit: 255
    t.string   "mtb_category",                          limit: 255
    t.string   "occupation",                            limit: 255
    t.boolean  "official_interest",                                 default: false, null: false
    t.boolean  "race_promotion_interest",                           default: false, null: false
    t.boolean  "team_interest",                                     default: false, null: false
    t.boolean  "volunteer_interest",                                default: false, null: false
    t.boolean  "wants_mail",                                        default: false, null: false
    t.boolean  "wants_email",                                       default: false, null: false
    t.string   "road_category",                         limit: 255
    t.string   "team_name",                             limit: 255
    t.string   "track_category",                        limit: 255
    t.string   "emergency_contact",                     limit: 255
    t.string   "emergency_contact_phone",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "work_phone",                            limit: 255
    t.string   "cell_fax",                              limit: 255
  end

  add_index "order_people", ["order_id"], name: "index_order_people_on_order_id", using: :btree
  add_index "order_people", ["person_id"], name: "index_order_people_on_person_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.decimal  "purchase_price",                 precision: 10, scale: 2
    t.string   "notes",             limit: 2000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",            limit: 255,                           default: "new", null: false
    t.datetime "purchase_time"
    t.string   "ip_address",        limit: 255
    t.boolean  "waiver_accepted"
    t.string   "error_message",     limit: 2048
    t.string   "previous_status",   limit: 255
    t.boolean  "suggest",                                                 default: true
    t.decimal  "old_purchase_fees",              precision: 10, scale: 2
    t.string   "gateway",           limit: 255
  end

  add_index "orders", ["gateway"], name: "index_orders_on_gateway", using: :btree
  add_index "orders", ["purchase_time"], name: "index_orders_on_purchase_time", using: :btree
  add_index "orders", ["status"], name: "index_orders_on_status", using: :btree
  add_index "orders", ["updated_at"], name: "index_orders_on_updated_at", using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer  "parent_id",  limit: 4
    t.text     "body",       limit: 65535,              null: false
    t.string   "path",       limit: 255,   default: "", null: false
    t.string   "slug",       limit: 255,   default: "", null: false
    t.string   "title",      limit: 255,   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["parent_id"], name: "parent_id", using: :btree
  add_index "pages", ["path"], name: "index_pages_on_path", unique: true, using: :btree
  add_index "pages", ["slug"], name: "index_pages_on_slug", using: :btree
  add_index "pages", ["updated_at"], name: "index_pages_on_updated_at", using: :btree

  create_table "payment_gateway_transactions", force: :cascade do |t|
    t.integer  "order_id",      limit: 4
    t.string   "action",        limit: 255
    t.integer  "amount",        limit: 4
    t.boolean  "success"
    t.string   "authorization", limit: 255
    t.text     "message",       limit: 65535
    t.text     "params",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "line_item_id",  limit: 4
  end

  add_index "payment_gateway_transactions", ["created_at"], name: "index_order_transactions_on_created_at", using: :btree
  add_index "payment_gateway_transactions", ["line_item_id"], name: "index_payment_gateway_transactions_on_line_item_id", using: :btree
  add_index "payment_gateway_transactions", ["order_id"], name: "index_order_transactions_on_order_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "first_name",                            limit: 64
    t.string   "last_name",                             limit: 255
    t.string   "city",                                  limit: 128
    t.date     "date_of_birth"
    t.string   "license",                               limit: 255
    t.text     "notes",                                 limit: 65535
    t.string   "state",                                 limit: 64
    t.integer  "team_id",                               limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cell_fax",                              limit: 255
    t.string   "ccx_category",                          limit: 255
    t.string   "dh_category",                           limit: 255
    t.string   "email",                                 limit: 255
    t.string   "gender",                                limit: 2
    t.string   "home_phone",                            limit: 255
    t.string   "mtb_category",                          limit: 255
    t.date     "member_from"
    t.string   "occupation",                            limit: 255
    t.string   "road_category",                         limit: 255
    t.string   "street",                                limit: 255
    t.string   "track_category",                        limit: 255
    t.string   "work_phone",                            limit: 255
    t.string   "zip",                                   limit: 255
    t.date     "member_to"
    t.boolean  "print_card",                                          default: false
    t.boolean  "ccx_only",                                            default: false, null: false
    t.string   "bmx_category",                          limit: 255
    t.boolean  "wants_email",                                         default: false, null: false
    t.boolean  "wants_mail",                                          default: false, null: false
    t.boolean  "volunteer_interest",                                  default: false, null: false
    t.boolean  "official_interest",                                   default: false, null: false
    t.boolean  "race_promotion_interest",                             default: false, null: false
    t.boolean  "team_interest",                                       default: false, null: false
    t.date     "member_usac_to"
    t.string   "status",                                limit: 255
    t.string   "crypted_password",                      limit: 255
    t.string   "password_salt",                         limit: 255
    t.string   "persistence_token",                     limit: 255
    t.string   "single_access_token",                   limit: 255
    t.string   "perishable_token",                      limit: 255
    t.integer  "login_count",                           limit: 4,     default: 0,     null: false
    t.integer  "failed_login_count",                    limit: 4,     default: 0,     null: false
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",                      limit: 255
    t.string   "last_login_ip",                         limit: 255
    t.string   "login",                                 limit: 100
    t.date     "license_expiration_date"
    t.string   "club_name",                             limit: 255
    t.string   "ncca_club_name",                        limit: 255
    t.string   "billing_first_name",                    limit: 255
    t.string   "billing_last_name",                     limit: 255
    t.string   "billing_street",                        limit: 255
    t.string   "billing_city",                          limit: 255
    t.string   "billing_state",                         limit: 255
    t.string   "billing_zip",                           limit: 255
    t.string   "billing_country_code",                  limit: 2,     default: "US"
    t.string   "card_brand",                            limit: 255
    t.date     "card_expires_on"
    t.boolean  "membership_address_is_billing_address",               default: true,  null: false
    t.string   "license_type",                          limit: 255
    t.string   "country_code",                          limit: 2,     default: "US"
    t.string   "emergency_contact",                     limit: 255
    t.string   "emergency_contact_phone",               limit: 255
    t.datetime "card_printed_at"
    t.boolean  "membership_card",                                     default: false, null: false
    t.boolean  "official",                                            default: false, null: false
    t.integer  "non_member_result_id",                  limit: 4
    t.string   "name",                                  limit: 255,   default: "",    null: false
    t.boolean  "other_people_with_same_name",                         default: false, null: false
  end

  add_index "people", ["crypted_password"], name: "index_people_on_crypted_password", using: :btree
  add_index "people", ["email"], name: "index_people_on_email", using: :btree
  add_index "people", ["first_name"], name: "idx_first_name", using: :btree
  add_index "people", ["last_name"], name: "idx_last_name", using: :btree
  add_index "people", ["login"], name: "index_people_on_login", using: :btree
  add_index "people", ["member_from"], name: "index_racers_on_member_from", using: :btree
  add_index "people", ["member_to"], name: "index_racers_on_member_to", using: :btree
  add_index "people", ["name"], name: "index_people_on_name", using: :btree
  add_index "people", ["non_member_result_id"], name: "index_people_on_non_member_result_id", using: :btree
  add_index "people", ["perishable_token"], name: "index_people_on_perishable_token", using: :btree
  add_index "people", ["persistence_token"], name: "index_people_on_persistence_token", using: :btree
  add_index "people", ["print_card"], name: "index_people_on_print_card", using: :btree
  add_index "people", ["single_access_token"], name: "index_people_on_single_access_token", using: :btree
  add_index "people", ["team_id"], name: "index_people_on_team_id", using: :btree
  add_index "people", ["updated_at"], name: "index_people_on_updated_at", using: :btree

  create_table "people_people", id: false, force: :cascade do |t|
    t.integer "person_id", limit: 4, null: false
    t.integer "editor_id", limit: 4, null: false
  end

  add_index "people_people", ["editor_id", "person_id"], name: "index_people_people_on_editor_id_and_person_id", unique: true, using: :btree
  add_index "people_people", ["editor_id"], name: "index_people_people_on_editor_id", using: :btree
  add_index "people_people", ["person_id"], name: "index_people_people_on_person_id", using: :btree

  create_table "people_roles", id: false, force: :cascade do |t|
    t.integer "role_id",   limit: 4, null: false
    t.integer "person_id", limit: 4, null: false
  end

  add_index "people_roles", ["person_id"], name: "index_people_roles_on_person_id", using: :btree
  add_index "people_roles", ["role_id"], name: "role_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.text     "caption",    limit: 65535
    t.string   "title",      limit: 255
    t.string   "image",      limit: 255
    t.integer  "height",     limit: 4
    t.integer  "width",      limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "link",       limit: 255
  end

  add_index "photos", ["updated_at"], name: "index_photos_on_updated_at", using: :btree

  create_table "posts", force: :cascade do |t|
    t.text     "body",                 limit: 65535,              null: false
    t.datetime "date",                                            null: false
    t.string   "subject",              limit: 255,   default: "", null: false
    t.string   "topica_message_id",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mailing_list_id",      limit: 4,     default: 0,  null: false
    t.integer  "position",             limit: 4
    t.string   "from_name",            limit: 255
    t.string   "from_email",           limit: 255
    t.datetime "last_reply_at"
    t.string   "last_reply_from_name", limit: 255
    t.integer  "original_id",          limit: 4
    t.integer  "replies_count",        limit: 4,     default: 0,  null: false
  end

  add_index "posts", ["date", "mailing_list_id"], name: "idx_date_list", using: :btree
  add_index "posts", ["date"], name: "idx_date", using: :btree
  add_index "posts", ["last_reply_at"], name: "index_posts_on_last_reply_at", using: :btree
  add_index "posts", ["mailing_list_id"], name: "idx_mailing_list_id", using: :btree
  add_index "posts", ["original_id"], name: "index_posts_on_original_id", using: :btree
  add_index "posts", ["position"], name: "index_posts_on_position", using: :btree
  add_index "posts", ["subject"], name: "idx_subject", using: :btree
  add_index "posts", ["topica_message_id"], name: "idx_topica_message_id", unique: true, using: :btree
  add_index "posts", ["updated_at"], name: "index_posts_on_updated_at", using: :btree

  create_table "product_variants", force: :cascade do |t|
    t.integer  "product_id", limit: 4,                                            null: false
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",                  precision: 10, scale: 2
    t.integer  "position",   limit: 4,                            default: 0,     null: false
    t.integer  "inventory",  limit: 4
    t.boolean  "default",                                         default: false, null: false
    t.boolean  "additional",                                      default: false, null: false
    t.integer  "quantity",   limit: 4,                            default: 1,     null: false
  end

  add_index "product_variants", ["product_id"], name: "index_product_variants_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.string   "description",               limit: 255
    t.decimal  "price",                                 precision: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id",                  limit: 4
    t.boolean  "notify_racing_association",                            default: false, null: false
    t.integer  "inventory",                 limit: 4
    t.boolean  "seller_pays_fee",                                      default: false, null: false
    t.string   "type",                      limit: 255
    t.boolean  "suggest",                                              default: false, null: false
    t.string   "image_url",                 limit: 255
    t.boolean  "dependent",                                            default: false, null: false
    t.integer  "seller_id",                 limit: 4
    t.boolean  "has_amount",                                           default: false
    t.boolean  "donation",                                             default: false
    t.boolean  "unique",                                               default: false, null: false
    t.string   "email",                     limit: 255
    t.boolean  "concussion_waver_required",                            default: false
    t.boolean  "quantity",                                             default: false, null: false
    t.integer  "default_quantity",          limit: 4,                  default: 1,     null: false
    t.boolean  "team_name",                                            default: false, null: false
  end

  add_index "products", ["event_id"], name: "index_products_on_event_id", using: :btree
  add_index "products", ["seller_id"], name: "index_products_on_seller_id", using: :btree
  add_index "products", ["type"], name: "index_products_on_type", using: :btree

  create_table "race_numbers", force: :cascade do |t|
    t.integer  "person_id",        limit: 4,   default: 0,  null: false
    t.integer  "discipline_id",    limit: 4,   default: 0,  null: false
    t.integer  "number_issuer_id", limit: 4,   default: 0,  null: false
    t.string   "value",            limit: 255, default: "", null: false
    t.integer  "year",             limit: 4,   default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "race_numbers", ["discipline_id"], name: "discipline_id", using: :btree
  add_index "race_numbers", ["number_issuer_id"], name: "number_issuer_id", using: :btree
  add_index "race_numbers", ["person_id"], name: "racer_id", using: :btree
  add_index "race_numbers", ["value"], name: "race_numbers_value_index", using: :btree
  add_index "race_numbers", ["year"], name: "index_race_numbers_on_year", using: :btree

  create_table "races", force: :cascade do |t|
    t.integer  "category_id",          limit: 4,                                              null: false
    t.string   "city",                 limit: 128
    t.string   "distance",             limit: 255
    t.string   "state",                limit: 64
    t.integer  "field_size",           limit: 4
    t.integer  "laps",                 limit: 4
    t.float    "time",                 limit: 24
    t.integer  "finishers",            limit: 4
    t.string   "notes",                limit: 255,                            default: ""
    t.string   "sanctioned_by",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "result_columns",       limit: 255
    t.integer  "bar_points",           limit: 4
    t.integer  "event_id",             limit: 4,                                              null: false
    t.decimal  "custom_price",                       precision: 10, scale: 2
    t.text     "custom_columns",       limit: 65535
    t.boolean  "full",                                                        default: false, null: false
    t.integer  "field_limit",          limit: 4
    t.boolean  "additional_race_only",                                        default: false, null: false
    t.boolean  "visible",                                                     default: true
  end

  add_index "races", ["bar_points"], name: "index_races_on_bar_points", using: :btree
  add_index "races", ["category_id"], name: "index_races_on_category_id", using: :btree
  add_index "races", ["event_id"], name: "index_races_on_event_id", using: :btree
  add_index "races", ["updated_at"], name: "index_races_on_updated_at", using: :btree

  create_table "racing_associations", force: :cascade do |t|
    t.boolean  "add_members_from_results",                                       default: true,                                  null: false
    t.boolean  "always_insert_table_headers",                                    default: true,                                  null: false
    t.boolean  "award_cat4_participation_points",                                default: true,                                  null: false
    t.boolean  "bmx_numbers",                                                    default: false,                                 null: false
    t.boolean  "cx_memberships",                                                 default: false,                                 null: false
    t.boolean  "eager_match_on_license",                                         default: false,                                 null: false
    t.boolean  "flyers_in_new_window",                                           default: false,                                 null: false
    t.boolean  "gender_specific_numbers",                                        default: false,                                 null: false
    t.boolean  "include_multiday_events_on_schedule",                            default: false,                                 null: false
    t.boolean  "show_all_teams_on_public_page",                                  default: false,                                 null: false
    t.boolean  "show_calendar_view",                                             default: true,                                  null: false
    t.boolean  "show_events_velodrome",                                          default: true,                                  null: false
    t.boolean  "show_license",                                                   default: true,                                  null: false
    t.boolean  "show_only_association_sanctioned_races_on_calendar",             default: true,                                  null: false
    t.boolean  "show_practices_on_calendar",                                     default: false,                                 null: false
    t.boolean  "ssl",                                                            default: false,                                 null: false
    t.boolean  "usac_results_format",                                            default: false,                                 null: false
    t.integer  "cat4_womens_race_series_category_id",                limit: 4
    t.integer  "masters_age",                                        limit: 4,   default: 35,                                    null: false
    t.integer  "rental_numbers_end",                                 limit: 4
    t.integer  "rental_numbers_start",                               limit: 4
    t.string   "cat4_womens_race_series_points",                     limit: 255
    t.string   "administrator_tabs",                                 limit: 255
    t.string   "competitions",                                       limit: 255
    t.string   "country_code",                                       limit: 255, default: "US",                                  null: false
    t.string   "default_discipline",                                 limit: 255, default: "Road",                                null: false
    t.string   "default_sanctioned_by",                              limit: 255
    t.string   "email",                                              limit: 255, default: "scott.willson@gmail.com",             null: false
    t.string   "exempt_team_categories",                             limit: 255, default: "0",                                   null: false
    t.string   "membership_email",                                   limit: 255
    t.string   "name",                                               limit: 255, default: "Cascadia Bicycle Racing Association", null: false
    t.string   "rails_host",                                         limit: 255, default: "localhost:3000"
    t.string   "sanctioning_organizations",                          limit: 255
    t.string   "short_name",                                         limit: 255, default: "CBRA",                                null: false
    t.string   "show_events_sanctioning_org_event_id",               limit: 255, default: "0",                                   null: false
    t.string   "state",                                              limit: 255, default: "OR",                                  null: false
    t.string   "static_host",                                        limit: 255, default: "localhost",                           null: false
    t.string   "usac_region",                                        limit: 255, default: "North West",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "cat4_womens_race_series_end_date"
    t.boolean  "unregistered_teams_in_results",                                  default: true,                                  null: false
    t.date     "next_year_start_at"
    t.boolean  "mobile_site",                                                    default: false,                                 null: false
    t.date     "cat4_womens_race_series_start_date"
    t.boolean  "filter_schedule_by_sanctioning_organization",                    default: false,                                 null: false
    t.string   "result_questions_url",                               limit: 255
    t.boolean  "filter_schedule_by_region",                                      default: false,                                 null: false
    t.string   "default_region_id",                                  limit: 255
    t.boolean  "allow_iframes",                                                  default: false
    t.string   "payment_gateway_name",                               limit: 255, default: "elavon"
  end

  create_table "refunds", force: :cascade do |t|
    t.integer  "order_id",     limit: 4
    t.decimal  "amount",                 precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "line_item_id", limit: 4,                          null: false
  end

  add_index "refunds", ["line_item_id"], name: "index_refunds_on_line_item_id", using: :btree
  add_index "refunds", ["order_id"], name: "index_refunds_on_order_id", using: :btree

  create_table "regions", force: :cascade do |t|
    t.string   "name",           limit: 255, null: false
    t.string   "friendly_param", limit: 255, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "regions", ["friendly_param"], name: "index_regions_on_friendly_param", unique: true, using: :btree
  add_index "regions", ["name"], name: "index_regions_on_name", unique: true, using: :btree

  create_table "results", force: :cascade do |t|
    t.integer  "category_id",             limit: 4
    t.integer  "person_id",               limit: 4
    t.integer  "race_id",                 limit: 4,                     null: false
    t.integer  "team_id",                 limit: 4
    t.integer  "age",                     limit: 4
    t.string   "city",                    limit: 128
    t.datetime "date_of_birth"
    t.boolean  "is_series"
    t.string   "license",                 limit: 64,    default: ""
    t.string   "notes",                   limit: 255
    t.string   "number",                  limit: 16,    default: ""
    t.string   "place",                   limit: 8,     default: ""
    t.integer  "place_in_category",       limit: 4,     default: 0
    t.float    "points",                  limit: 24,    default: 0.0
    t.float    "points_from_place",       limit: 24,    default: 0.0
    t.float    "points_bonus_penalty",    limit: 24,    default: 0.0
    t.float    "points_total",            limit: 24,    default: 0.0
    t.string   "state",                   limit: 64
    t.string   "status",                  limit: 3
    t.float    "time",                    limit: 53
    t.float    "time_bonus_penalty",      limit: 53
    t.float    "time_gap_to_leader",      limit: 53
    t.float    "time_gap_to_previous",    limit: 53
    t.float    "time_gap_to_winner",      limit: 53
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "time_total",              limit: 53
    t.integer  "laps",                    limit: 4
    t.string   "members_only_place",      limit: 8
    t.integer  "points_bonus",            limit: 4,     default: 0,     null: false
    t.integer  "points_penalty",          limit: 4,     default: 0,     null: false
    t.boolean  "preliminary"
    t.boolean  "bar",                                   default: true
    t.string   "gender",                  limit: 8
    t.string   "category_class",          limit: 16
    t.string   "age_group",               limit: 16
    t.text     "custom_attributes",       limit: 65535
    t.boolean  "competition_result",                                    null: false
    t.boolean  "team_competition_result",                               null: false
    t.string   "category_name",           limit: 255
    t.string   "event_date_range_s",      limit: 255,                   null: false
    t.date     "date",                                                  null: false
    t.date     "event_end_date",                                        null: false
    t.integer  "event_id",                limit: 4,                     null: false
    t.string   "event_full_name",         limit: 255,                   null: false
    t.string   "first_name",              limit: 255
    t.string   "last_name",               limit: 255
    t.string   "name",                    limit: 255
    t.string   "race_name",               limit: 255,                   null: false
    t.string   "race_full_name",          limit: 255,                   null: false
    t.string   "team_name",               limit: 255
    t.integer  "year",                    limit: 4,                     null: false
    t.integer  "non_member_result_id",    limit: 4
    t.boolean  "single_event_license",                  default: false
    t.boolean  "team_member",                           default: false, null: false
  end

  add_index "results", ["category_id"], name: "index_results_on_category_id", using: :btree
  add_index "results", ["event_id"], name: "index_results_on_event_id", using: :btree
  add_index "results", ["members_only_place"], name: "index_results_on_members_only_place", using: :btree
  add_index "results", ["non_member_result_id"], name: "index_results_on_non_member_result_id", using: :btree
  add_index "results", ["person_id"], name: "idx_racer_id", using: :btree
  add_index "results", ["place"], name: "index_results_on_place", using: :btree
  add_index "results", ["race_id"], name: "idx_race_id", using: :btree
  add_index "results", ["team_id"], name: "index_results_on_team_id", using: :btree
  add_index "results", ["updated_at"], name: "index_results_on_updated_at", using: :btree
  add_index "results", ["year"], name: "index_results_on_year", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scores", force: :cascade do |t|
    t.integer  "competition_result_id", limit: 4
    t.integer  "source_result_id",      limit: 4
    t.float    "points",                limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date"
    t.string   "description",           limit: 255
    t.string   "event_name",            limit: 255
    t.string   "notes",                 limit: 255
  end

  add_index "scores", ["competition_result_id"], name: "scores_competition_result_id_index", using: :btree
  add_index "scores", ["source_result_id"], name: "scores_source_result_id_index", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",                limit: 255,  default: "",    null: false
    t.string   "city",                limit: 128
    t.string   "state",               limit: 64
    t.string   "notes",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "member",                           default: false
    t.string   "website",             limit: 255
    t.string   "sponsors",            limit: 1000
    t.string   "contact_name",        limit: 255
    t.string   "contact_email",       limit: 255
    t.string   "contact_phone",       limit: 255
    t.boolean  "show_on_public_page",              default: true
  end

  add_index "teams", ["name"], name: "index_teams_on_name", using: :btree
  add_index "teams", ["updated_at"], name: "index_teams_on_updated_at", using: :btree

  create_table "update_requests", force: :cascade do |t|
    t.integer  "order_person_id", limit: 4,   null: false
    t.datetime "expires_at",                  null: false
    t.string   "token",           limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "update_requests", ["expires_at"], name: "index_update_requests_on_expires_at", using: :btree
  add_index "update_requests", ["order_person_id"], name: "index_update_requests_on_order_person_id", unique: true, using: :btree
  add_index "update_requests", ["token"], name: "index_update_requests_on_token", using: :btree

  create_table "velodromes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "website",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "velodromes", ["name"], name: "index_velodromes_on_name", using: :btree

  create_table "versions", force: :cascade do |t|
    t.integer  "versioned_id",   limit: 4
    t.string   "versioned_type", limit: 255
    t.integer  "user_id",        limit: 4
    t.string   "user_type",      limit: 255
    t.string   "user_name",      limit: 255
    t.text     "modifications",  limit: 65535
    t.integer  "number",         limit: 4
    t.string   "tag",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reverted_from",  limit: 4
  end

  add_index "versions", ["created_at"], name: "index_versions_on_created_at", using: :btree
  add_index "versions", ["number"], name: "index_versions_on_number", using: :btree
  add_index "versions", ["tag"], name: "index_versions_on_tag", using: :btree
  add_index "versions", ["user_id", "user_type"], name: "index_versions_on_user_id_and_user_type", using: :btree
  add_index "versions", ["user_name"], name: "index_versions_on_user_name", using: :btree
  add_index "versions", ["versioned_id", "versioned_type"], name: "index_versions_on_versioned_id_and_versioned_type", using: :btree

  add_foreign_key "categories", "categories", column: "parent_id", name: "categories_categories_id_fk", on_delete: :cascade
  add_foreign_key "competition_event_memberships", "events", column: "competition_id", name: "competition_event_memberships_competitions_id_fk", on_delete: :cascade
  add_foreign_key "competition_event_memberships", "events", name: "competition_event_memberships_events_id_fk", on_delete: :cascade
  add_foreign_key "discipline_aliases", "disciplines", name: "discipline_aliases_disciplines_id_fk", on_delete: :cascade
  add_foreign_key "discipline_bar_categories", "categories", name: "discipline_bar_categories_categories_id_fk", on_delete: :cascade
  add_foreign_key "discipline_bar_categories", "disciplines", name: "discipline_bar_categories_disciplines_id_fk", on_delete: :cascade
  add_foreign_key "discount_codes", "events", name: "discount_codes_ibfk_1"
  add_foreign_key "duplicates_people", "duplicates", name: "duplicates_racers_duplicates_id_fk", on_delete: :cascade
  add_foreign_key "duplicates_people", "people", name: "duplicates_people_person_id", on_delete: :cascade
  add_foreign_key "editor_requests", "people", column: "editor_id", name: "editor_requests_ibfk_1", on_delete: :cascade
  add_foreign_key "editor_requests", "people", name: "editor_requests_ibfk_2", on_delete: :cascade
  add_foreign_key "events", "events", column: "parent_id", name: "events_events_id_fk", on_delete: :cascade
  add_foreign_key "events", "number_issuers", name: "events_number_issuers_id_fk"
  add_foreign_key "events", "people", column: "promoter_id", name: "events_promoter_id", on_delete: :nullify
  add_foreign_key "events", "velodromes", name: "events_velodrome_id_fk"
  add_foreign_key "order_people", "orders", name: "order_people_ibfk_2", on_delete: :cascade
  add_foreign_key "order_people", "people", name: "order_people_ibfk_1", on_delete: :cascade
  add_foreign_key "pages", "pages", column: "parent_id", name: "pages_parent_id_fk"
  add_foreign_key "people", "teams"
  add_foreign_key "people_people", "people", column: "editor_id", name: "people_people_ibfk_1", on_delete: :cascade
  add_foreign_key "people_people", "people", name: "people_people_ibfk_2", on_delete: :cascade
  add_foreign_key "people_roles", "people", name: "people_roles_person_id", on_delete: :cascade
  add_foreign_key "people_roles", "roles", name: "roles_users_role_id_fk", on_delete: :cascade
  add_foreign_key "posts", "mailing_lists", name: "posts_mailing_list_id_fk"
  add_foreign_key "race_numbers", "disciplines", name: "race_numbers_discipline_id_fk"
  add_foreign_key "race_numbers", "number_issuers", name: "race_numbers_number_issuer_id_fk"
  add_foreign_key "race_numbers", "people", name: "race_numbers_person_id", on_delete: :cascade
  add_foreign_key "races", "categories"
  add_foreign_key "races", "events", name: "races_event_id_fk", on_delete: :cascade
  add_foreign_key "results", "categories"
  add_foreign_key "results", "people", name: "results_person_id"
  add_foreign_key "results", "races", name: "results_race_id_fk", on_delete: :cascade
  add_foreign_key "results", "teams"
  add_foreign_key "scores", "results", column: "competition_result_id", name: "scores_competition_result_id_fk", on_delete: :cascade
  add_foreign_key "scores", "results", column: "source_result_id", name: "scores_source_result_id_fk", on_delete: :cascade
  add_foreign_key "update_requests", "order_people", name: "update_requests_ibfk_1", on_delete: :cascade
end
