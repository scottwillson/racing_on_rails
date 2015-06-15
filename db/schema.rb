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

ActiveRecord::Schema.define(version: 20150614235447) do

  create_table "adjustments", force: true do |t|
    t.integer  "order_id"
    t.integer  "person_id"
    t.datetime "date"
    t.decimal  "amount",      precision: 10, scale: 2
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aliases", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "aliasable_type", null: false
    t.integer  "aliasable_id",   null: false
  end

  add_index "aliases", ["aliasable_id"], name: "index_aliases_on_aliasable_id", using: :btree
  add_index "aliases", ["aliasable_type"], name: "index_aliases_on_aliasable_type", using: :btree
  add_index "aliases", ["name", "aliasable_type"], name: "index_aliases_on_name_and_aliasable_type", unique: true, using: :btree
  add_index "aliases", ["name"], name: "index_aliases_on_name", using: :btree

  create_table "article_categories", force: true do |t|
    t.string   "name"
    t.integer  "parent_id",   default: 0
    t.integer  "position",    default: 0
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "article_categories", ["updated_at"], name: "index_article_categories_on_updated_at", using: :btree

  create_table "articles", force: true do |t|
    t.string   "title"
    t.string   "heading"
    t.string   "description"
    t.boolean  "display"
    t.text     "body"
    t.integer  "position",            default: 0
    t.integer  "article_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles", ["article_category_id"], name: "index_articles_on_article_category_id", using: :btree
  add_index "articles", ["updated_at"], name: "index_articles_on_updated_at", using: :btree

  create_table "bank_statements", force: true do |t|
    t.decimal  "american_express_fees",        precision: 10, scale: 2
    t.decimal  "american_express_gross",       precision: 10, scale: 2
    t.decimal  "credit_card_transaction_fees", precision: 10, scale: 2
    t.decimal  "credit_card_percentage_fees",  precision: 10, scale: 2
    t.decimal  "credit_card_gross",            precision: 10, scale: 2
    t.integer  "items"
    t.integer  "refunds"
    t.decimal  "gross",                        precision: 10, scale: 2
    t.decimal  "refunds_gross",                precision: 10, scale: 2
    t.decimal  "other_fees",                   precision: 10, scale: 2
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bids", force: true do |t|
    t.string   "name",       null: false
    t.string   "email",      null: false
    t.string   "phone",      null: false
    t.integer  "amount",     null: false
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.integer  "position",                  default: 0,   null: false
    t.string   "name",           limit: 64, default: "",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "ages_begin",                default: 0
    t.integer  "ages_end",                  default: 999
    t.string   "friendly_param",                          null: false
    t.integer  "ability",                   default: 0,   null: false
    t.string   "gender",                    default: "M", null: false
  end

  add_index "categories", ["friendly_param"], name: "index_categories_on_friendly_param", using: :btree
  add_index "categories", ["name"], name: "categories_name_index", unique: true, using: :btree
  add_index "categories", ["parent_id"], name: "parent_id", using: :btree
  add_index "categories", ["updated_at"], name: "index_categories_on_updated_at", using: :btree

  create_table "competition_event_memberships", force: true do |t|
    t.integer "competition_id",                          null: false
    t.integer "event_id",                                null: false
    t.float   "points_factor",  limit: 24, default: 1.0
    t.string  "notes"
  end

  add_index "competition_event_memberships", ["competition_id"], name: "index_competition_event_memberships_on_competition_id", using: :btree
  add_index "competition_event_memberships", ["event_id"], name: "index_competition_event_memberships_on_event_id", using: :btree

  create_table "discipline_aliases", id: false, force: true do |t|
    t.integer  "discipline_id",            default: 0,  null: false
    t.string   "alias",         limit: 64, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discipline_aliases", ["alias"], name: "idx_alias", using: :btree
  add_index "discipline_aliases", ["discipline_id"], name: "idx_discipline_id", using: :btree

  create_table "discipline_bar_categories", id: false, force: true do |t|
    t.integer "category_id",   default: 0, null: false
    t.integer "discipline_id", default: 0, null: false
  end

  add_index "discipline_bar_categories", ["category_id", "discipline_id"], name: "discipline_bar_categories_category_id_index", unique: true, using: :btree
  add_index "discipline_bar_categories", ["category_id"], name: "idx_category_id", using: :btree
  add_index "discipline_bar_categories", ["discipline_id"], name: "idx_discipline_id", using: :btree

  create_table "disciplines", force: true do |t|
    t.string   "name",       limit: 64, default: "",    null: false
    t.boolean  "bar"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "numbers",               default: false
  end

  add_index "disciplines", ["name"], name: "index_disciplines_on_name", unique: true, using: :btree

  create_table "discount_codes", force: true do |t|
    t.integer  "event_id",                                             null: false
    t.string   "name"
    t.string   "code",                                                 null: false
    t.integer  "created_by_id"
    t.string   "created_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",          precision: 10, scale: 2
    t.integer  "quantity",                                 default: 1, null: false
    t.integer  "used_count",                               default: 0, null: false
  end

  add_index "discount_codes", ["event_id"], name: "event_id", using: :btree

  create_table "duplicates", force: true do |t|
    t.text "new_attributes"
  end

  create_table "duplicates_people", id: false, force: true do |t|
    t.integer "person_id"
    t.integer "duplicate_id"
  end

  add_index "duplicates_people", ["duplicate_id"], name: "index_duplicates_racers_on_duplicate_id", using: :btree
  add_index "duplicates_people", ["person_id", "duplicate_id"], name: "index_duplicates_racers_on_racer_id_and_duplicate_id", unique: true, using: :btree
  add_index "duplicates_people", ["person_id"], name: "index_duplicates_racers_on_racer_id", using: :btree

  create_table "editor_requests", force: true do |t|
    t.integer  "person_id",  null: false
    t.integer  "editor_id",  null: false
    t.datetime "expires_at", null: false
    t.string   "token",      null: false
    t.string   "email",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "editor_requests", ["editor_id", "person_id"], name: "index_editor_requests_on_editor_id_and_person_id", unique: true, using: :btree
  add_index "editor_requests", ["editor_id"], name: "index_editor_requests_on_editor_id", using: :btree
  add_index "editor_requests", ["expires_at"], name: "index_editor_requests_on_expires_at", using: :btree
  add_index "editor_requests", ["person_id"], name: "index_editor_requests_on_person_id", using: :btree
  add_index "editor_requests", ["token"], name: "index_editor_requests_on_token", using: :btree

  create_table "editors_events", id: false, force: true do |t|
    t.integer "event_id",  null: false
    t.integer "editor_id", null: false
  end

  add_index "editors_events", ["editor_id"], name: "index_editors_events_on_editor_id", using: :btree
  add_index "editors_events", ["event_id"], name: "index_editors_events_on_event_id", using: :btree

  create_table "events", force: true do |t|
    t.integer  "parent_id"
    t.string   "city",                           limit: 128
    t.date     "date"
    t.string   "discipline",                     limit: 32
    t.string   "flyer"
    t.string   "name"
    t.string   "notes",                                                               default: ""
    t.string   "sanctioned_by"
    t.string   "state",                          limit: 64
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flyer_approved",                                                      default: false, null: false
    t.boolean  "cancelled",                                                           default: false
    t.integer  "number_issuer_id"
    t.string   "first_aid_provider"
    t.float    "pre_event_fees",                 limit: 24
    t.float    "post_event_fees",                limit: 24
    t.float    "flyer_ad_fee",                   limit: 24
    t.string   "prize_list"
    t.integer  "velodrome_id"
    t.string   "time"
    t.boolean  "instructional",                                                       default: false
    t.boolean  "practice",                                                            default: false
    t.boolean  "atra_points_series",                                                  default: false, null: false
    t.integer  "bar_points",                                                                          null: false
    t.boolean  "ironman",                                                                             null: false
    t.boolean  "auto_combined_results",                                               default: true,  null: false
    t.integer  "team_id"
    t.string   "sanctioning_org_event_id",       limit: 16
    t.integer  "promoter_id"
    t.string   "phone"
    t.string   "email"
    t.decimal  "price",                                      precision: 10, scale: 2
    t.boolean  "postponed",                                                           default: false, null: false
    t.string   "chief_referee"
    t.boolean  "registration",                                                        default: false, null: false
    t.boolean  "beginner_friendly",                                                   default: false, null: false
    t.boolean  "promoter_pays_registration_fee",                                      default: false, null: false
    t.boolean  "membership_required",                                                 default: false, null: false
    t.datetime "registration_ends_at"
    t.boolean  "override_registration_ends_at",                                       default: false, null: false
    t.decimal  "all_events_discount",                        precision: 10, scale: 2
    t.decimal  "additional_race_price",                      precision: 10, scale: 2
    t.string   "website"
    t.string   "registration_link"
    t.string   "custom_suggestion"
    t.integer  "field_limit"
    t.text     "refund_policy"
    t.boolean  "refunds",                                                             default: true,  null: false
    t.integer  "region_id"
    t.date     "end_date",                                                                            null: false
    t.boolean  "registration_public",                                                 default: true,  null: false
    t.decimal  "junior_price",                               precision: 10, scale: 2
    t.boolean  "suggest_membership",                                                  default: true,  null: false
  end

  add_index "events", ["bar_points"], name: "index_events_on_bar_points", using: :btree
  add_index "events", ["date"], name: "idx_date", using: :btree
  add_index "events", ["discipline"], name: "idx_disciplined", using: :btree
  add_index "events", ["number_issuer_id"], name: "events_number_issuer_id_index", using: :btree
  add_index "events", ["parent_id"], name: "parent_id", using: :btree
  add_index "events", ["promoter_id"], name: "index_events_on_promoter_id", using: :btree
  add_index "events", ["region_id"], name: "index_events_on_region_id", using: :btree
  add_index "events", ["sanctioned_by"], name: "index_events_on_sanctioned_by", using: :btree
  add_index "events", ["type"], name: "idx_type", using: :btree
  add_index "events", ["type"], name: "index_events_on_type", using: :btree
  add_index "events", ["updated_at"], name: "index_events_on_updated_at", using: :btree
  add_index "events", ["velodrome_id"], name: "velodrome_id", using: :btree

  create_table "homes", force: true do |t|
    t.integer  "photo_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "weeks_of_recent_results",  default: 2, null: false
    t.integer  "weeks_of_upcoming_events", default: 2, null: false
  end

  add_index "homes", ["updated_at"], name: "index_homes_on_updated_at", using: :btree

  create_table "import_files", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_items", force: true do |t|
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.integer  "race_id"
    t.decimal  "amount",                         precision: 10, scale: 2
    t.string   "string_value"
    t.boolean  "boolean_value"
    t.string   "type",                                                    default: "LineItem", null: false
    t.boolean  "promoter_pays_registration_fee",                          default: false,      null: false
    t.decimal  "purchase_price",                 precision: 10, scale: 2
    t.integer  "person_id"
    t.integer  "year"
    t.integer  "discount_code_id"
    t.integer  "line_item_id"
    t.integer  "product_id"
    t.integer  "product_variant_id"
    t.string   "status",                                                  default: "new",      null: false
    t.datetime "effective_purchased_at"
    t.integer  "additional_product_variant_id"
    t.integer  "purchased_discount_code_id"
    t.integer  "quantity",                                                default: 1,          null: false
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

  create_table "mailing_lists", force: true do |t|
    t.string   "name",                default: "",   null: false
    t.string   "friendly_name",       default: "",   null: false
    t.string   "subject_line_prefix", default: "",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "public",              default: true, null: false
  end

  add_index "mailing_lists", ["name"], name: "idx_name", using: :btree
  add_index "mailing_lists", ["updated_at"], name: "index_mailing_lists_on_updated_at", using: :btree

  create_table "names", force: true do |t|
    t.integer  "nameable_id",   null: false
    t.string   "name",          null: false
    t.integer  "year",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nameable_type"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "names", ["name"], name: "index_names_on_name", using: :btree
  add_index "names", ["nameable_id"], name: "team_id", using: :btree
  add_index "names", ["nameable_type"], name: "index_names_on_nameable_type", using: :btree
  add_index "names", ["year"], name: "index_names_on_year", using: :btree

  create_table "non_member_results", force: true do |t|
    t.boolean  "visible",          default: true
    t.integer  "person_id"
    t.integer  "size",             default: 0
    t.date     "recent_result_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "non_member_results_people", id: false, force: true do |t|
    t.integer "non_member_result_id"
    t.integer "person_id"
  end

  create_table "number_issuers", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "number_issuers", ["name"], name: "number_issuers_name_index", unique: true, using: :btree

  create_table "offline_single_event_licenses", force: true do |t|
    t.integer  "event_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_people", force: true do |t|
    t.integer  "person_id"
    t.integer  "order_id"
    t.boolean  "owner",                                           default: false, null: false
    t.boolean  "membership_card",                                 default: false, null: false
    t.date     "date_of_birth"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country_code",                          limit: 2, default: "US"
    t.boolean  "membership_address_is_billing_address",           default: true,  null: false
    t.string   "billing_first_name"
    t.string   "billing_last_name"
    t.string   "billing_street"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_zip"
    t.string   "billing_country_code",                  limit: 2, default: "US"
    t.date     "card_expires_on"
    t.string   "card_brand"
    t.string   "ccx_category"
    t.string   "dh_category"
    t.string   "email"
    t.string   "home_phone"
    t.string   "first_name"
    t.string   "gender"
    t.string   "last_name"
    t.string   "mtb_category"
    t.string   "occupation"
    t.boolean  "official_interest",                               default: false, null: false
    t.boolean  "race_promotion_interest",                         default: false, null: false
    t.boolean  "team_interest",                                   default: false, null: false
    t.boolean  "volunteer_interest",                              default: false, null: false
    t.boolean  "wants_mail",                                      default: false, null: false
    t.boolean  "wants_email",                                     default: false, null: false
    t.string   "road_category"
    t.string   "team_name"
    t.string   "track_category"
    t.string   "emergency_contact"
    t.string   "emergency_contact_phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "work_phone"
    t.string   "cell_fax"
  end

  add_index "order_people", ["order_id"], name: "index_order_people_on_order_id", using: :btree
  add_index "order_people", ["person_id"], name: "index_order_people_on_person_id", using: :btree

  create_table "orders", force: true do |t|
    t.decimal  "purchase_price",                 precision: 10, scale: 2
    t.string   "notes",             limit: 2000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                                                  default: "new", null: false
    t.datetime "purchase_time"
    t.string   "ip_address"
    t.boolean  "waiver_accepted"
    t.string   "error_message",     limit: 2048
    t.string   "previous_status"
    t.boolean  "suggest",                                                 default: true
    t.decimal  "old_purchase_fees",              precision: 10, scale: 2
  end

  add_index "orders", ["purchase_time"], name: "index_orders_on_purchase_time", using: :btree
  add_index "orders", ["status"], name: "index_orders_on_status", using: :btree
  add_index "orders", ["updated_at"], name: "index_orders_on_updated_at", using: :btree

  create_table "pages", force: true do |t|
    t.integer  "parent_id"
    t.text     "body",                    null: false
    t.string   "path",       default: "", null: false
    t.string   "slug",       default: "", null: false
    t.string   "title",      default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["parent_id"], name: "parent_id", using: :btree
  add_index "pages", ["path"], name: "index_pages_on_path", unique: true, using: :btree
  add_index "pages", ["slug"], name: "index_pages_on_slug", using: :btree
  add_index "pages", ["updated_at"], name: "index_pages_on_updated_at", using: :btree

  create_table "payment_gateway_transactions", force: true do |t|
    t.integer  "order_id"
    t.string   "action"
    t.integer  "amount"
    t.boolean  "success"
    t.string   "authorization"
    t.string   "message"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "line_item_id"
  end

  add_index "payment_gateway_transactions", ["created_at"], name: "index_order_transactions_on_created_at", using: :btree
  add_index "payment_gateway_transactions", ["line_item_id"], name: "index_payment_gateway_transactions_on_line_item_id", using: :btree
  add_index "payment_gateway_transactions", ["order_id"], name: "index_order_transactions_on_order_id", using: :btree

  create_table "people", force: true do |t|
    t.string   "first_name",                            limit: 64
    t.string   "last_name"
    t.string   "city",                                  limit: 128
    t.date     "date_of_birth"
    t.string   "license",                               limit: 64
    t.text     "notes"
    t.string   "state",                                 limit: 64
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cell_fax"
    t.string   "ccx_category"
    t.string   "dh_category"
    t.string   "email"
    t.string   "gender",                                limit: 2
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
    t.boolean  "print_card",                                        default: false
    t.boolean  "ccx_only",                                          default: false, null: false
    t.string   "bmx_category"
    t.boolean  "wants_email",                                       default: false, null: false
    t.boolean  "wants_mail",                                        default: false, null: false
    t.boolean  "volunteer_interest",                                default: false, null: false
    t.boolean  "official_interest",                                 default: false, null: false
    t.boolean  "race_promotion_interest",                           default: false, null: false
    t.boolean  "team_interest",                                     default: false, null: false
    t.date     "member_usac_to"
    t.string   "status"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "login_count",                                       default: 0,     null: false
    t.integer  "failed_login_count",                                default: 0,     null: false
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "login",                                 limit: 100
    t.date     "license_expiration_date"
    t.string   "club_name"
    t.string   "ncca_club_name"
    t.string   "billing_first_name"
    t.string   "billing_last_name"
    t.string   "billing_street"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_zip"
    t.string   "billing_country_code",                  limit: 2,   default: "US"
    t.string   "card_brand"
    t.date     "card_expires_on"
    t.boolean  "membership_address_is_billing_address",             default: true,  null: false
    t.string   "license_type"
    t.string   "country_code",                          limit: 2,   default: "US"
    t.string   "emergency_contact"
    t.string   "emergency_contact_phone"
    t.datetime "card_printed_at"
    t.boolean  "membership_card",                                   default: false, null: false
    t.boolean  "official",                                          default: false, null: false
    t.integer  "non_member_result_id"
    t.string   "name",                                              default: "",    null: false
    t.boolean  "other_people_with_same_name",                       default: false, null: false
  end

  add_index "people", ["crypted_password"], name: "index_people_on_crypted_password", using: :btree
  add_index "people", ["email"], name: "index_people_on_email", using: :btree
  add_index "people", ["first_name"], name: "idx_first_name", using: :btree
  add_index "people", ["last_name"], name: "idx_last_name", using: :btree
  add_index "people", ["license"], name: "index_people_on_license", using: :btree
  add_index "people", ["login"], name: "index_people_on_login", using: :btree
  add_index "people", ["member_from"], name: "index_racers_on_member_from", using: :btree
  add_index "people", ["member_to"], name: "index_racers_on_member_to", using: :btree
  add_index "people", ["name"], name: "index_people_on_name", using: :btree
  add_index "people", ["non_member_result_id"], name: "index_people_on_non_member_result_id", using: :btree
  add_index "people", ["perishable_token"], name: "index_people_on_perishable_token", using: :btree
  add_index "people", ["persistence_token"], name: "index_people_on_persistence_token", using: :btree
  add_index "people", ["print_card"], name: "index_people_on_print_card", using: :btree
  add_index "people", ["single_access_token"], name: "index_people_on_single_access_token", using: :btree
  add_index "people", ["team_id"], name: "idx_team_id", using: :btree
  add_index "people", ["updated_at"], name: "index_people_on_updated_at", using: :btree

  create_table "people_people", id: false, force: true do |t|
    t.integer "person_id", null: false
    t.integer "editor_id", null: false
  end

  add_index "people_people", ["editor_id", "person_id"], name: "index_people_people_on_editor_id_and_person_id", unique: true, using: :btree
  add_index "people_people", ["editor_id"], name: "index_people_people_on_editor_id", using: :btree
  add_index "people_people", ["person_id"], name: "index_people_people_on_person_id", using: :btree

  create_table "people_roles", id: false, force: true do |t|
    t.integer "role_id",   null: false
    t.integer "person_id", null: false
  end

  add_index "people_roles", ["person_id"], name: "index_people_roles_on_person_id", using: :btree
  add_index "people_roles", ["role_id"], name: "role_id", using: :btree

  create_table "photos", force: true do |t|
    t.text     "caption"
    t.string   "title"
    t.string   "image"
    t.integer  "height"
    t.integer  "width"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "link"
  end

  add_index "photos", ["updated_at"], name: "index_photos_on_updated_at", using: :btree

  create_table "posts", force: true do |t|
    t.text     "body",                              null: false
    t.datetime "date",                              null: false
    t.string   "subject",              default: "", null: false
    t.string   "topica_message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mailing_list_id",      default: 0,  null: false
    t.integer  "position"
    t.string   "from_name"
    t.string   "from_email"
    t.datetime "last_reply_at"
    t.string   "last_reply_from_name"
    t.integer  "original_id"
    t.integer  "replies_count",        default: 0,  null: false
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

  create_table "product_variants", force: true do |t|
    t.integer  "product_id",                                          null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",      precision: 10, scale: 2
    t.integer  "position",                            default: 0,     null: false
    t.integer  "inventory"
    t.boolean  "default",                             default: false, null: false
    t.boolean  "additional",                          default: false, null: false
    t.integer  "quantity",                            default: 1,     null: false
  end

  add_index "product_variants", ["product_id"], name: "index_product_variants_on_product_id", using: :btree

  create_table "products", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.decimal  "price",                     precision: 10, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.boolean  "notify_racing_association",                          default: false, null: false
    t.integer  "inventory"
    t.boolean  "seller_pays_fee",                                    default: false, null: false
    t.string   "type"
    t.boolean  "suggest",                                            default: false, null: false
    t.string   "image_url"
    t.boolean  "dependent",                                          default: false, null: false
    t.integer  "seller_id"
    t.boolean  "has_amount",                                         default: false
    t.boolean  "donation",                                           default: false
    t.boolean  "unique",                                             default: false, null: false
    t.string   "email"
    t.boolean  "concussion_waver_required",                          default: false
    t.boolean  "quantity",                                           default: false, null: false
    t.integer  "default_quantity",                                   default: 1,     null: false
    t.boolean  "team_name",                                          default: false, null: false
  end

  add_index "products", ["event_id"], name: "index_products_on_event_id", using: :btree
  add_index "products", ["seller_id"], name: "index_products_on_seller_id", using: :btree
  add_index "products", ["type"], name: "index_products_on_type", using: :btree

  create_table "race_numbers", force: true do |t|
    t.integer  "person_id",        default: 0,  null: false
    t.integer  "discipline_id",    default: 0,  null: false
    t.integer  "number_issuer_id", default: 0,  null: false
    t.string   "value",            default: "", null: false
    t.integer  "year",             default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "race_numbers", ["discipline_id"], name: "discipline_id", using: :btree
  add_index "race_numbers", ["number_issuer_id"], name: "number_issuer_id", using: :btree
  add_index "race_numbers", ["person_id"], name: "racer_id", using: :btree
  add_index "race_numbers", ["value"], name: "race_numbers_value_index", using: :btree
  add_index "race_numbers", ["year"], name: "index_race_numbers_on_year", using: :btree

  create_table "races", force: true do |t|
    t.integer  "category_id",                                                               null: false
    t.string   "city",                 limit: 128
    t.string   "distance"
    t.string   "state",                limit: 64
    t.integer  "field_size"
    t.integer  "laps"
    t.float    "time",                 limit: 24
    t.integer  "finishers"
    t.string   "notes",                                                     default: ""
    t.string   "sanctioned_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "result_columns"
    t.integer  "bar_points"
    t.integer  "event_id",                                                                  null: false
    t.decimal  "custom_price",                     precision: 10, scale: 2
    t.text     "custom_columns"
    t.boolean  "full",                                                      default: false, null: false
    t.integer  "field_limit"
    t.boolean  "additional_race_only",                                      default: false, null: false
    t.boolean  "visible",                                                   default: true
  end

  add_index "races", ["bar_points"], name: "index_races_on_bar_points", using: :btree
  add_index "races", ["category_id"], name: "idx_category_id", using: :btree
  add_index "races", ["event_id"], name: "index_races_on_event_id", using: :btree
  add_index "races", ["updated_at"], name: "index_races_on_updated_at", using: :btree

  create_table "racing_associations", force: true do |t|
    t.boolean  "add_members_from_results",                           default: true,                                  null: false
    t.boolean  "always_insert_table_headers",                        default: true,                                  null: false
    t.boolean  "award_cat4_participation_points",                    default: true,                                  null: false
    t.boolean  "bmx_numbers",                                        default: false,                                 null: false
    t.boolean  "cx_memberships",                                     default: false,                                 null: false
    t.boolean  "eager_match_on_license",                             default: false,                                 null: false
    t.boolean  "flyers_in_new_window",                               default: false,                                 null: false
    t.boolean  "gender_specific_numbers",                            default: false,                                 null: false
    t.boolean  "include_multiday_events_on_schedule",                default: false,                                 null: false
    t.boolean  "show_all_teams_on_public_page",                      default: false,                                 null: false
    t.boolean  "show_calendar_view",                                 default: true,                                  null: false
    t.boolean  "show_events_velodrome",                              default: true,                                  null: false
    t.boolean  "show_license",                                       default: true,                                  null: false
    t.boolean  "show_only_association_sanctioned_races_on_calendar", default: true,                                  null: false
    t.boolean  "show_practices_on_calendar",                         default: false,                                 null: false
    t.boolean  "ssl",                                                default: false,                                 null: false
    t.boolean  "usac_results_format",                                default: false,                                 null: false
    t.integer  "cat4_womens_race_series_category_id"
    t.integer  "masters_age",                                        default: 35,                                    null: false
    t.integer  "rental_numbers_end"
    t.integer  "rental_numbers_start"
    t.string   "cat4_womens_race_series_points"
    t.string   "administrator_tabs"
    t.string   "competitions"
    t.string   "country_code",                                       default: "US",                                  null: false
    t.string   "default_discipline",                                 default: "Road",                                null: false
    t.string   "default_sanctioned_by"
    t.string   "email",                                              default: "scott.willson@gmail.com",             null: false
    t.string   "exempt_team_categories",                             default: "0",                                   null: false
    t.string   "membership_email"
    t.string   "name",                                               default: "Cascadia Bicycle Racing Association", null: false
    t.string   "rails_host",                                         default: "localhost:3000"
    t.string   "sanctioning_organizations"
    t.string   "short_name",                                         default: "CBRA",                                null: false
    t.string   "show_events_sanctioning_org_event_id",               default: "0",                                   null: false
    t.string   "state",                                              default: "OR",                                  null: false
    t.string   "static_host",                                        default: "localhost",                           null: false
    t.string   "usac_region",                                        default: "North West",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "cat4_womens_race_series_end_date"
    t.boolean  "unregistered_teams_in_results",                      default: true,                                  null: false
    t.date     "next_year_start_at"
    t.boolean  "mobile_site",                                        default: false,                                 null: false
    t.date     "cat4_womens_race_series_start_date"
    t.boolean  "filter_schedule_by_sanctioning_organization",        default: false,                                 null: false
    t.string   "result_questions_url"
    t.boolean  "filter_schedule_by_region",                          default: false,                                 null: false
    t.string   "default_region_id"
    t.boolean  "allow_iframes",                                      default: false
  end

  create_table "refunds", force: true do |t|
    t.integer  "order_id"
    t.decimal  "amount",       precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "line_item_id",                          null: false
  end

  add_index "refunds", ["line_item_id"], name: "index_refunds_on_line_item_id", using: :btree
  add_index "refunds", ["order_id"], name: "index_refunds_on_order_id", using: :btree

  create_table "regions", force: true do |t|
    t.string   "name",           null: false
    t.string   "friendly_param", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "regions", ["friendly_param"], name: "index_regions_on_friendly_param", unique: true, using: :btree
  add_index "regions", ["name"], name: "index_regions_on_name", unique: true, using: :btree

  create_table "results", force: true do |t|
    t.integer  "category_id"
    t.integer  "person_id"
    t.integer  "race_id",                                             null: false
    t.integer  "team_id"
    t.integer  "age"
    t.string   "city",                    limit: 128
    t.datetime "date_of_birth"
    t.boolean  "is_series"
    t.string   "license",                 limit: 64,  default: ""
    t.string   "notes"
    t.string   "number",                  limit: 16,  default: ""
    t.string   "place",                   limit: 8,   default: ""
    t.integer  "place_in_category",                   default: 0
    t.float    "points",                  limit: 24,  default: 0.0
    t.float    "points_from_place",       limit: 24,  default: 0.0
    t.float    "points_bonus_penalty",    limit: 24,  default: 0.0
    t.float    "points_total",            limit: 24,  default: 0.0
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
    t.integer  "laps"
    t.string   "members_only_place",      limit: 8
    t.integer  "points_bonus",                        default: 0,     null: false
    t.integer  "points_penalty",                      default: 0,     null: false
    t.boolean  "preliminary"
    t.boolean  "bar",                                 default: true
    t.string   "gender",                  limit: 8
    t.string   "category_class",          limit: 16
    t.string   "age_group",               limit: 16
    t.text     "custom_attributes"
    t.boolean  "competition_result",                                  null: false
    t.boolean  "team_competition_result",                             null: false
    t.string   "category_name"
    t.string   "event_date_range_s",                                  null: false
    t.date     "date",                                                null: false
    t.date     "event_end_date",                                      null: false
    t.integer  "event_id",                                            null: false
    t.string   "event_full_name",                                     null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "name"
    t.string   "race_name",                                           null: false
    t.string   "race_full_name",                                      null: false
    t.string   "team_name"
    t.integer  "year",                                                null: false
    t.integer  "non_member_result_id"
    t.boolean  "single_event_license",                default: false
    t.boolean  "team_member",                         default: false, null: false
  end

  add_index "results", ["category_id"], name: "idx_category_id", using: :btree
  add_index "results", ["event_id"], name: "index_results_on_event_id", using: :btree
  add_index "results", ["members_only_place"], name: "index_results_on_members_only_place", using: :btree
  add_index "results", ["non_member_result_id"], name: "index_results_on_non_member_result_id", using: :btree
  add_index "results", ["person_id"], name: "idx_racer_id", using: :btree
  add_index "results", ["place"], name: "index_results_on_place", using: :btree
  add_index "results", ["race_id"], name: "idx_race_id", using: :btree
  add_index "results", ["team_id"], name: "idx_team_id", using: :btree
  add_index "results", ["updated_at"], name: "index_results_on_updated_at", using: :btree
  add_index "results", ["year"], name: "index_results_on_year", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scores", force: true do |t|
    t.integer  "competition_result_id"
    t.integer  "source_result_id"
    t.float    "points",                limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date"
    t.string   "description"
    t.string   "event_name"
    t.string   "notes"
  end

  add_index "scores", ["competition_result_id"], name: "scores_competition_result_id_index", using: :btree
  add_index "scores", ["source_result_id"], name: "scores_source_result_id_index", using: :btree

  create_table "teams", force: true do |t|
    t.string   "name",                             default: "",    null: false
    t.string   "city",                limit: 128
    t.string   "state",               limit: 64
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "member",                           default: false
    t.string   "website"
    t.string   "sponsors",            limit: 1000
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.boolean  "show_on_public_page",              default: true
  end

  add_index "teams", ["name"], name: "idx_name", unique: true, using: :btree
  add_index "teams", ["updated_at"], name: "index_teams_on_updated_at", using: :btree

  create_table "update_requests", force: true do |t|
    t.integer  "order_person_id", null: false
    t.datetime "expires_at",      null: false
    t.string   "token",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "update_requests", ["expires_at"], name: "index_update_requests_on_expires_at", using: :btree
  add_index "update_requests", ["order_person_id"], name: "index_update_requests_on_order_person_id", unique: true, using: :btree
  add_index "update_requests", ["token"], name: "index_update_requests_on_token", using: :btree

  create_table "velodromes", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "velodromes", ["name"], name: "index_velodromes_on_name", using: :btree

  create_table "versions", force: true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "modifications"
    t.integer  "number"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reverted_from"
  end

  add_index "versions", ["created_at"], name: "index_versions_on_created_at", using: :btree
  add_index "versions", ["number"], name: "index_versions_on_number", using: :btree
  add_index "versions", ["tag"], name: "index_versions_on_tag", using: :btree
  add_index "versions", ["user_id", "user_type"], name: "index_versions_on_user_id_and_user_type", using: :btree
  add_index "versions", ["user_name"], name: "index_versions_on_user_name", using: :btree
  add_index "versions", ["versioned_id", "versioned_type"], name: "index_versions_on_versioned_id_and_versioned_type", using: :btree

end
