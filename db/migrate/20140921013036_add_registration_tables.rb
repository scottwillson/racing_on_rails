class AddRegistrationTables < ActiveRecord::Migration
  def change
    return true if table_exists?("adjustments")

    create_table "adjustments" do |t|
      t.integer  "order_id"
      t.integer  "person_id"
      t.datetime "date"
      t.decimal  "amount",      precision: 10, scale: 2
      t.string   "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "bank_statements" do |t|
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

    create_table "discount_codes" do |t|
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

    change_table :events do |t|
      t.decimal  "price",                                      precision: 10, scale: 2
      t.boolean  "registration",                                                        default: false, null: false
      t.boolean  "promoter_pays_registration_fee",                                      default: false, null: false
      t.boolean  "membership_required",                                                 default: false, null: false
      t.datetime "registration_ends_at"
      t.boolean  "override_registration_ends_at",                                       default: false, null: false
      t.decimal  "all_events_discount",                        precision: 10, scale: 2
      t.decimal  "additional_race_price",                      precision: 10, scale: 2
      t.string   "custom_suggestion"
      t.integer  "field_limit"
      t.text     "refund_policy"
      t.boolean  "refunds",                                                             default: true,  null: false
      t.boolean  "registration_public",                                                 default: true,  null: false
    end

    create_table "line_items" do |t|
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

    create_table "non_member_results" do |t|
      t.boolean  "visible",          default: true
      t.integer  "person_id"
      t.integer  "size",             default: 0
      t.date     "recent_result_on"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "non_member_results_people", id: false do |t|
      t.integer "non_member_result_id"
      t.integer "person_id"
    end

    create_table "offline_single_event_licenses" do |t|
      t.integer  "event_id"
      t.integer  "person_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "order_people" do |t|
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

    create_table "orders" do |t|
      t.decimal  "purchase_price",                 precision: 10, scale: 2
      t.string   "notes",             limit: 2000
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "status",                                                  default: "new", null: false
      t.datetime "purchase_time"
      t.string   "ip_address"
      t.boolean  "waiver_accepted"
      t.string   "error_message"
      t.string   "previous_status"
      t.boolean  "suggest",                                                 default: true
      t.decimal  "old_purchase_fees",              precision: 10, scale: 2
    end

    add_index "orders", ["purchase_time"], name: "index_orders_on_purchase_time", using: :btree
    add_index "orders", ["status"], name: "index_orders_on_status", using: :btree
    add_index "orders", ["updated_at"], name: "index_orders_on_updated_at", using: :btree

    create_table "payment_gateway_transactions" do |t|
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

    change_table :people do |t|
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
      t.integer  "non_member_result_id"
    end

    add_index "people", ["non_member_result_id"], name: "index_people_on_non_member_result_id", using: :btree

    create_table "product_variants" do |t|
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

    create_table "products" do |t|
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

    change_table :races do |t|
       t.decimal  "custom_price",                     precision: 10, scale: 2
       t.boolean  "full",                                                      default: false, null: false
       t.boolean  "additional_race_only",                                      default: false, null: false
    end

    create_table "refunds" do |t|
      t.integer  "order_id"
      t.decimal  "amount",       precision: 10, scale: 2
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "line_item_id",                          null: false
    end

    add_index "refunds", ["line_item_id"], name: "index_refunds_on_line_item_id", using: :btree
    add_index "refunds", ["order_id"], name: "index_refunds_on_order_id", using: :btree

    change_table :results do |t|
      t.integer  "non_member_result_id"
      t.boolean  "single_event_license",                default: false
    end

    add_index "results", ["non_member_result_id"], name: "index_results_on_non_member_result_id", using: :btree

    create_table "update_requests" do |t|
      t.integer  "order_person_id", null: false
      t.datetime "expires_at",      null: false
      t.string   "token",           null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "update_requests", ["expires_at"], name: "index_update_requests_on_expires_at", using: :btree
    add_index "update_requests", ["order_person_id"], name: "index_update_requests_on_order_person_id", unique: true, using: :btree
    add_index "update_requests", ["token"], name: "index_update_requests_on_token", using: :btree
  end
end
