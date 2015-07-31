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

ActiveRecord::Schema.define(version: 20150731050401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "account_entries", force: :cascade do |t|
    t.integer  "account_txn_id",                           null: false
    t.integer  "account_id",                               null: false
    t.string   "type",                                     null: false
    t.decimal  "amount",          precision: 10, scale: 2, null: false
    t.text     "remarks"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.hstore   "additional_info"
    t.string   "mode",                                     null: false
  end

  add_index "account_entries", ["account_txn_id", "account_id"], name: "index_account_entries_on_account_txn_id_and_account_id", using: :btree

  create_table "account_txns", force: :cascade do |t|
    t.integer  "business_entity_id",             null: false
    t.integer  "currency_id",                    null: false
    t.integer  "voucher_sequence_id",            null: false
    t.integer  "created_by_id",                  null: false
    t.string   "type",                           null: false
    t.string   "number_prefix",       limit: 8
    t.integer  "number",                         null: false
    t.text     "remarks"
    t.datetime "txn_date",                       null: false
    t.integer  "status",                         null: false
    t.string   "ref_number",          limit: 30
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "account_txns", ["business_entity_id", "number_prefix", "number"], name: "idx_account_txns_on_business_entity_n_number_prefix_n_number", unique: true, using: :btree
  add_index "account_txns", ["created_by_id"], name: "index_account_txns_on_created_by_id", using: :btree
  add_index "account_txns", ["currency_id"], name: "index_account_txns_on_currency_id", using: :btree
  add_index "account_txns", ["voucher_sequence_id"], name: "index_account_txns_on_voucher_sequence_id", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.integer  "business_entity_id",                             null: false
    t.string   "name",               limit: 100
    t.string   "alias_name",         limit: 25
    t.string   "type",                                           null: false
    t.boolean  "contra",                         default: false, null: false
    t.boolean  "reserved",                       default: false, null: false
    t.boolean  "active",                         default: true,  null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "accounts", ["alias_name", "business_entity_id"], name: "index_accounts_on_alias_name_and_business_entity_id", unique: true, using: :btree
  add_index "accounts", ["name", "business_entity_id"], name: "index_accounts_on_name_and_business_entity_id", unique: true, using: :btree

  create_table "authors", force: :cascade do |t|
    t.string   "name",       limit: 100,                null: false
    t.boolean  "active",                 default: true, null: false
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "authors", ["name"], name: "index_authors_on_name", unique: true, using: :btree

  create_table "bank_reconciliations", force: :cascade do |t|
    t.integer  "account_entry_id", null: false
    t.integer  "reconciled_by_id"
    t.datetime "reconciled_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "bank_reconciliations", ["account_entry_id"], name: "index_bank_reconciliations_on_account_entry_id", unique: true, using: :btree

  create_table "business_entities", force: :cascade do |t|
    t.string   "name",                     limit: 200,                 null: false
    t.string   "alias_name",               limit: 40,                  null: false
    t.boolean  "active",                               default: true,  null: false
    t.integer  "city_id",                                              null: false
    t.integer  "registration_status",                                  null: false
    t.string   "email",                    limit: 150
    t.text     "primary_address",                                      null: false
    t.text     "shipping_address"
    t.string   "contact_number_primary",   limit: 15
    t.string   "contact_number_secondary", limit: 15
    t.hstore   "legal_details"
    t.integer  "position"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "classification",                       default: 1,     null: false
    t.boolean  "reserved",                             default: false, null: false
  end

  add_index "business_entities", ["alias_name"], name: "index_business_entities_on_alias_name", unique: true, using: :btree
  add_index "business_entities", ["classification"], name: "index_business_entities_on_classification", using: :btree
  add_index "business_entities", ["name", "city_id"], name: "index_business_entities_on_name_and_city_id", unique: true, using: :btree

  create_table "business_entity_locations", force: :cascade do |t|
    t.integer  "business_entity_id",                null: false
    t.string   "name",                              null: false
    t.boolean  "active",             default: true, null: false
    t.integer  "position"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "cash_account_id"
    t.integer  "bank_account_id"
    t.integer  "sales_account_id"
  end

  add_index "business_entity_locations", ["bank_account_id"], name: "index_business_entity_locations_on_bank_account_id", using: :btree
  add_index "business_entity_locations", ["business_entity_id", "name"], name: "index_business_entity_locations_on_business_entity_id_and_name", unique: true, using: :btree
  add_index "business_entity_locations", ["cash_account_id"], name: "index_business_entity_locations_on_cash_account_id", using: :btree
  add_index "business_entity_locations", ["sales_account_id"], name: "index_business_entity_locations_on_sales_account_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 100,                null: false
    t.string   "ancestry"
    t.boolean  "active",                 default: true, null: false
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "code",       limit: 3,                  null: false
  end

  add_index "categories", ["ancestry"], name: "index_categories_on_ancestry", using: :btree
  add_index "categories", ["code"], name: "index_categories_on_code", unique: true, using: :btree
  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "cities", force: :cascade do |t|
    t.string   "name",       limit: 50,                 null: false
    t.integer  "state_id",                              null: false
    t.integer  "zone_id",                               null: false
    t.boolean  "active",                default: true,  null: false
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "reserved",              default: false, null: false
  end

  add_index "cities", ["name", "state_id"], name: "index_cities_on_name_and_state_id", unique: true, using: :btree
  add_index "cities", ["name", "zone_id"], name: "index_cities_on_name_and_zone_id", unique: true, using: :btree

  create_table "core_levels", force: :cascade do |t|
    t.string   "name",       limit: 100,                null: false
    t.boolean  "active",                 default: true, null: false
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "core_levels", ["name"], name: "index_core_levels_on_name", unique: true, using: :btree

  create_table "currencies", force: :cascade do |t|
    t.string   "name",       limit: 100,                 null: false
    t.string   "code",       limit: 3,                   null: false
    t.boolean  "active",                 default: true,  null: false
    t.integer  "position"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "reserved",               default: false, null: false
  end

  add_index "currencies", ["code"], name: "index_currencies_on_code", unique: true, using: :btree
  add_index "currencies", ["name"], name: "index_currencies_on_name", unique: true, using: :btree

  create_table "distribution_types", force: :cascade do |t|
    t.string   "name",       limit: 100,                null: false
    t.boolean  "active",                 default: true, null: false
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "distribution_types", ["name"], name: "index_distribution_types_on_name", unique: true, using: :btree

  create_table "focus_groups", force: :cascade do |t|
    t.string   "name",       limit: 100,                null: false
    t.boolean  "active",                 default: true
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "focus_groups", ["name"], name: "index_focus_groups_on_name", unique: true, using: :btree

  create_table "inventory_txn_line_items", force: :cascade do |t|
    t.integer  "inventory_txn_id",                          null: false
    t.integer  "product_id",                                null: false
    t.integer  "quantity_out"
    t.decimal  "amount",           precision: 10, scale: 2, null: false
    t.decimal  "tax_amount",       precision: 10, scale: 2, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.decimal  "price",            precision: 8,  scale: 2, null: false
    t.decimal  "tax_rate",         precision: 5,  scale: 2, null: false
    t.integer  "quantity_in"
  end

  add_index "inventory_txn_line_items", ["inventory_txn_id", "product_id"], name: "idx_inventory_txn_line_items_on_sale_invoice_id_and_product_id", unique: true, using: :btree

  create_table "inventory_txns", force: :cascade do |t|
    t.text     "remarks"
    t.decimal  "total_amount",                          precision: 10, scale: 2, null: false
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.decimal  "tax_amount",                            precision: 10, scale: 2, null: false
    t.datetime "voucher_date",                                                   null: false
    t.integer  "status",                                                         null: false
    t.string   "ref_number",                 limit: 30
    t.integer  "voucher_sequence_id",                                            null: false
    t.decimal  "goods_value",                           precision: 10, scale: 2, null: false
    t.text     "address"
    t.hstore   "tax_details"
    t.integer  "number",                                                         null: false
    t.string   "number_prefix",              limit: 8
    t.integer  "primary_location_id",                                            null: false
    t.integer  "created_by_id",                                                  null: false
    t.string   "customer_membership_number", limit: 9
    t.integer  "primary_entity_id",                                              null: false
    t.integer  "secondary_entity_id"
    t.integer  "secondary_location_id"
    t.string   "type",                                                           null: false
    t.integer  "invoice_id"
  end

  add_index "inventory_txns", ["created_by_id"], name: "index_inventory_txns_on_created_by_id", using: :btree
  add_index "inventory_txns", ["invoice_id"], name: "index_inventory_txns_on_invoice_id", order: {"invoice_id"=>:desc}, using: :btree
  add_index "inventory_txns", ["number", "number_prefix", "voucher_sequence_id"], name: "idx_sale_invoices_on_number_n_prefix_n_voucher_sequence", unique: true, using: :btree
  add_index "inventory_txns", ["primary_entity_id"], name: "index_inventory_txns_on_primary_entity_id", using: :btree
  add_index "inventory_txns", ["primary_location_id"], name: "index_inventory_txns_on_primary_location_id", using: :btree
  add_index "inventory_txns", ["secondary_entity_id"], name: "index_inventory_txns_on_secondary_entity_id", using: :btree
  add_index "inventory_txns", ["secondary_location_id"], name: "index_inventory_txns_on_secondary_location_id", using: :btree

  create_table "invoice_headers", force: :cascade do |t|
    t.integer  "account_txn_id",                        null: false
    t.text     "address"
    t.hstore   "legal_details"
    t.string   "customer_membership_number",  limit: 9
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "business_entity_location_id",           null: false
  end

  add_index "invoice_headers", ["account_txn_id"], name: "index_invoice_headers_on_account_txn_id", unique: true, using: :btree
  add_index "invoice_headers", ["business_entity_location_id"], name: "index_invoice_headers_on_business_entity_location_id", using: :btree

  create_table "invoice_line_items", force: :cascade do |t|
    t.integer  "account_txn_id",                                      null: false
    t.integer  "product_id",                                          null: false
    t.integer  "quantity",                                            null: false
    t.decimal  "price",                      precision: 10, scale: 2, null: false
    t.decimal  "goods_value",                precision: 12, scale: 2, null: false
    t.decimal  "tax_rate",                   precision: 5,  scale: 2, null: false
    t.decimal  "tax_amount",                 precision: 10, scale: 2, null: false
    t.decimal  "amount",                     precision: 12, scale: 2, null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "state_category_tax_rate_id"
  end

  add_index "invoice_line_items", ["account_txn_id", "product_id"], name: "index_invoice_line_items_on_account_txn_id_and_product_id", unique: true, using: :btree
  add_index "invoice_line_items", ["account_txn_id"], name: "index_invoice_line_items_on_account_txn_id", using: :btree
  add_index "invoice_line_items", ["product_id"], name: "index_invoice_line_items_on_product_id", using: :btree
  add_index "invoice_line_items", ["state_category_tax_rate_id"], name: "index_invoice_line_items_on_state_category_tax_rate_id", using: :btree

  create_table "invoice_payments", force: :cascade do |t|
    t.integer  "invoice_id",                                  null: false
    t.integer  "mode_id",                                     null: false
    t.integer  "received_by_id",                              null: false
    t.decimal  "amount",             precision: 10, scale: 2, null: false
    t.hstore   "additional_details"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "invoice_payments", ["invoice_id", "mode_id"], name: "index_invoice_payments_on_invoice_id_and_mode_id", unique: true, using: :btree
  add_index "invoice_payments", ["received_by_id"], name: "index_invoice_payments_on_received_by_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "currency_id",                                                    null: false
    t.integer  "voucher_sequence_id",                                            null: false
    t.integer  "primary_location_id",                                            null: false
    t.integer  "secondary_entity_id",                                            null: false
    t.integer  "created_by_id",                                                  null: false
    t.integer  "number",                                                         null: false
    t.string   "number_prefix",              limit: 8
    t.text     "remarks"
    t.datetime "invoice_date",                                                   null: false
    t.integer  "status",                                                         null: false
    t.string   "ref_number",                 limit: 30
    t.decimal  "goods_value",                           precision: 10, scale: 2, null: false
    t.decimal  "tax_amount",                            precision: 10, scale: 2, null: false
    t.decimal  "total_amount",                          precision: 10, scale: 2, null: false
    t.text     "address"
    t.hstore   "tax_details"
    t.string   "customer_membership_number", limit: 9
    t.string   "type",                                                           null: false
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  add_index "invoices", ["created_by_id"], name: "index_invoices_on_created_by_id", using: :btree
  add_index "invoices", ["currency_id"], name: "index_invoices_on_currency_id", using: :btree
  add_index "invoices", ["invoice_date"], name: "index_invoices_on_invoice_date", using: :btree
  add_index "invoices", ["number_prefix", "number"], name: "index_invoices_on_number_prefix_and_number", unique: true, using: :btree
  add_index "invoices", ["type"], name: "index_invoices_on_type", using: :btree
  add_index "invoices", ["voucher_sequence_id", "number"], name: "index_invoices_on_voucher_sequence_id_and_number", unique: true, using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name",       limit: 100,                null: false
    t.string   "ancestry"
    t.boolean  "active",                 default: true, null: false
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "code",       limit: 3,                  null: false
  end

  add_index "languages", ["code"], name: "index_languages_on_code", unique: true, using: :btree
  add_index "languages", ["name"], name: "index_languages_on_name", unique: true, using: :btree

  create_table "order_line_items", force: :cascade do |t|
    t.integer  "order_id",                            null: false
    t.integer  "product_id",                          null: false
    t.integer  "quantity",                            null: false
    t.decimal  "amount",     precision: 10, scale: 2, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "order_line_items", ["order_id", "product_id"], name: "index_order_line_items_on_order_id_and_product_id", unique: true, using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "currency_id",                                                     null: false
    t.integer  "booked_by_id",                                                    null: false
    t.text     "remarks"
    t.decimal  "total_amount",            precision: 10, scale: 2,                null: false
    t.string   "number",       limit: 10,                                         null: false
    t.boolean  "active",                                           default: true, null: false
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
  end

  add_index "orders", ["booked_by_id"], name: "index_orders_on_booked_by_id", using: :btree
  add_index "orders", ["currency_id"], name: "index_orders_on_currency_id", using: :btree
  add_index "orders", ["number"], name: "index_orders_on_number", unique: true, using: :btree

  create_table "payment_modes", force: :cascade do |t|
    t.string   "name",            limit: 100,                null: false
    t.boolean  "active",                      default: true, null: false
    t.integer  "position"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "show_on_invoice",             default: true, null: false
  end

  add_index "payment_modes", ["name"], name: "index_payment_modes_on_name", unique: true, using: :btree

  create_table "product_groups", force: :cascade do |t|
    t.string   "name",       limit: 100,                null: false
    t.boolean  "active",                 default: true, null: false
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "product_groups", ["name"], name: "index_product_groups_on_name", unique: true, using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "product_group_id"
    t.integer  "category_id",                                                            null: false
    t.integer  "core_level_id"
    t.integer  "author_id"
    t.integer  "distribution_type_id",                                    default: 1,    null: false
    t.integer  "language_id"
    t.integer  "publisher_id",                                            default: 1,    null: false
    t.integer  "uom_id",                                                  default: 1,    null: false
    t.integer  "focus_group_id",                                          default: 1
    t.integer  "sku",                                                                    null: false
    t.string   "name",                                                                   null: false
    t.string   "alias_name",           limit: 40,                                        null: false
    t.text     "summary"
    t.text     "synopsis"
    t.date     "publication_date"
    t.decimal  "mrp",                             precision: 8, scale: 2,                null: false
    t.decimal  "selling_price",                   precision: 8, scale: 2,                null: false
    t.string   "isbn"
    t.text     "notes"
    t.hstore   "details"
    t.boolean  "active",                                                  default: true, null: false
    t.integer  "position"
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
  end

  add_index "products", ["alias_name", "language_id", "category_id", "selling_price"], name: "idx_prodcts_on_alias_name_n_language_n_category_n_selling_price", unique: true, using: :btree
  add_index "products", ["author_id"], name: "index_products_on_author_id", using: :btree
  add_index "products", ["core_level_id"], name: "index_products_on_core_level_id", using: :btree
  add_index "products", ["distribution_type_id"], name: "index_products_on_distribution_type_id", using: :btree
  add_index "products", ["focus_group_id"], name: "index_products_on_focus_group_id", using: :btree
  add_index "products", ["name", "category_id", "language_id", "selling_price"], name: "idx_product_category_language_selling_price_unique", unique: true, using: :btree
  add_index "products", ["product_group_id"], name: "index_products_on_product_group_id", using: :btree
  add_index "products", ["publisher_id"], name: "index_products_on_publisher_id", using: :btree
  add_index "products", ["sku"], name: "index_products_on_sku", unique: true, using: :btree

  create_table "publishers", force: :cascade do |t|
    t.integer  "business_entity_id",                null: false
    t.boolean  "active",             default: true, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "publishers", ["business_entity_id"], name: "index_publishers_on_business_entity_id", unique: true, using: :btree

  create_table "regions", force: :cascade do |t|
    t.string   "name",        limit: 50,                 null: false
    t.string   "code",        limit: 3,                  null: false
    t.integer  "currency_id",                            null: false
    t.boolean  "active",                 default: true,  null: false
    t.integer  "position"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "reserved",               default: false, null: false
  end

  add_index "regions", ["code"], name: "index_regions_on_code", unique: true, using: :btree
  add_index "regions", ["currency_id"], name: "index_regions_on_currency_id", using: :btree
  add_index "regions", ["name"], name: "index_regions_on_name", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",         limit: 40,                 null: false
    t.boolean  "mail_enabled",            default: true,  null: false
    t.boolean  "reserved",                default: false, null: false
    t.boolean  "active",                  default: true,  null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true, using: :btree

  create_table "state_category_tax_rates", force: :cascade do |t|
    t.integer  "state_id",                                                           null: false
    t.integer  "category_id",                                                        null: false
    t.integer  "classification",                                      default: 1,    null: false
    t.string   "interstate_label", limit: 10,                                        null: false
    t.decimal  "interstate_rate",             precision: 5, scale: 2,                null: false
    t.string   "intrastate_label", limit: 10,                                        null: false
    t.decimal  "intrastate_rate",             precision: 5, scale: 2,                null: false
    t.datetime "valid_from",                                                         null: false
    t.datetime "valid_till"
    t.boolean  "active",                                              default: true
    t.integer  "position"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
  end

  add_index "state_category_tax_rates", ["state_id", "category_id", "valid_from"], name: "idx_state_cat_tax_rates_on_state_n_cat_n_valid_from", unique: true, using: :btree

  create_table "states", force: :cascade do |t|
    t.string   "name",       limit: 50,                 null: false
    t.integer  "region_id",                             null: false
    t.string   "code",       limit: 3,                  null: false
    t.boolean  "active",                default: true,  null: false
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "reserved",              default: false, null: false
  end

  add_index "states", ["code"], name: "index_states_on_code", unique: true, using: :btree
  add_index "states", ["name", "region_id"], name: "index_states_on_name_and_region_id", unique: true, using: :btree

  create_table "uoms", force: :cascade do |t|
    t.string   "name",       limit: 50,                null: false
    t.string   "print_name", limit: 5,                 null: false
    t.boolean  "active",                default: true, null: false
    t.integer  "position"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "uoms", ["name"], name: "index_uoms_on_name", unique: true, using: :btree
  add_index "uoms", ["print_name"], name: "index_uoms_on_print_name", unique: true, using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id",                                     null: false
    t.integer  "role_id",                                     null: false
    t.integer  "business_entity_id"
    t.integer  "business_entity_location_id"
    t.boolean  "global",                      default: false, null: false
    t.boolean  "active",                      default: true,  null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "user_roles", ["user_id", "role_id", "business_entity_id"], name: "idx_user_on_role_on_business_entity", unique: true, where: "(business_entity_id IS NOT NULL)", using: :btree
  add_index "user_roles", ["user_id", "role_id", "business_entity_location_id"], name: "idx_user_on_role_on_business_entity_location", unique: true, where: "(business_entity_location_id IS NOT NULL)", using: :btree
  add_index "user_roles", ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true, where: "((business_entity_id IS NOT NULL) AND (business_entity_location_id IS NOT NULL))", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                       limit: 100,                 null: false
    t.integer  "city_id",                                                null: false
    t.string   "email",                      limit: 100,                 null: false
    t.string   "password_digest",                                        null: false
    t.string   "contact_number_primary",     limit: 15
    t.string   "contact_number_secondary",   limit: 15
    t.text     "address"
    t.boolean  "active",                                 default: false
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "sign_in_count"
    t.string   "auth_token",                                             null: false
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "email_confirmation_token"
    t.datetime "email_confirmation_sent_at"
    t.datetime "confirmed_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.integer  "position"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "membership_number",          limit: 9,                   null: false
    t.boolean  "reserved",                               default: false, null: false
    t.integer  "cash_account_id"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
  add_index "users", ["cash_account_id"], name: "index_users_on_cash_account_id", using: :btree
  add_index "users", ["city_id"], name: "index_users_on_city_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["membership_number"], name: "index_users_on_membership_number", unique: true, using: :btree

  create_table "voucher_sequences", force: :cascade do |t|
    t.integer  "business_entity_id",                          null: false
    t.integer  "classification",               default: 1,    null: false
    t.string   "number_prefix",      limit: 8
    t.integer  "starting_number",              default: 1,    null: false
    t.datetime "valid_from",                                  null: false
    t.datetime "valid_till"
    t.text     "terms_conditions"
    t.boolean  "active",                       default: true, null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "voucher_sequences", ["classification", "business_entity_id", "valid_from", "number_prefix"], name: "idx_voucher_seq_on_num_prfx_bus_entity_n_clasfctn_n_valid_from", unique: true, where: "(number_prefix IS NOT NULL)", using: :btree
  add_index "voucher_sequences", ["classification", "business_entity_id", "valid_from"], name: "idx_voucher_seq_on_business_entity_n_classification_n_valid_fro", unique: true, where: "(number_prefix IS NULL)", using: :btree

  create_table "zones", force: :cascade do |t|
    t.string   "name",       limit: 50,                 null: false
    t.integer  "region_id",                             null: false
    t.string   "code",       limit: 3,                  null: false
    t.boolean  "active",                default: true,  null: false
    t.integer  "position"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "reserved",              default: false, null: false
  end

  add_index "zones", ["code"], name: "index_zones_on_code", unique: true, using: :btree
  add_index "zones", ["name", "region_id"], name: "index_zones_on_name_and_region_id", unique: true, using: :btree

  add_foreign_key "account_entries", "account_txns", on_delete: :cascade
  add_foreign_key "account_entries", "accounts", on_delete: :cascade
  add_foreign_key "account_txns", "business_entities", on_delete: :restrict
  add_foreign_key "account_txns", "currencies", on_delete: :restrict
  add_foreign_key "account_txns", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "account_txns", "voucher_sequences", on_delete: :restrict
  add_foreign_key "accounts", "business_entities", on_delete: :restrict
  add_foreign_key "bank_reconciliations", "account_entries", on_delete: :restrict
  add_foreign_key "bank_reconciliations", "users", column: "reconciled_by_id", on_delete: :restrict
  add_foreign_key "business_entities", "cities", on_delete: :restrict
  add_foreign_key "business_entity_locations", "accounts", column: "bank_account_id", on_delete: :restrict
  add_foreign_key "business_entity_locations", "accounts", column: "cash_account_id", on_delete: :restrict
  add_foreign_key "business_entity_locations", "accounts", column: "sales_account_id", on_delete: :restrict
  add_foreign_key "business_entity_locations", "business_entities", on_delete: :restrict
  add_foreign_key "cities", "states", on_delete: :restrict
  add_foreign_key "cities", "zones", on_delete: :restrict
  add_foreign_key "inventory_txn_line_items", "inventory_txns", on_delete: :restrict
  add_foreign_key "inventory_txn_line_items", "products", on_delete: :restrict
  add_foreign_key "inventory_txns", "business_entities", column: "primary_entity_id", on_delete: :restrict
  add_foreign_key "inventory_txns", "business_entities", column: "secondary_entity_id", on_delete: :restrict
  add_foreign_key "inventory_txns", "business_entity_locations", column: "primary_location_id", on_delete: :restrict
  add_foreign_key "inventory_txns", "business_entity_locations", column: "secondary_location_id", on_delete: :restrict
  add_foreign_key "inventory_txns", "invoices", on_delete: :restrict
  add_foreign_key "inventory_txns", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "inventory_txns", "voucher_sequences", on_delete: :restrict
  add_foreign_key "invoice_headers", "account_txns", on_delete: :cascade
  add_foreign_key "invoice_headers", "business_entity_locations", on_delete: :cascade
  add_foreign_key "invoice_line_items", "account_txns", on_delete: :cascade
  add_foreign_key "invoice_line_items", "products", on_delete: :cascade
  add_foreign_key "invoice_line_items", "state_category_tax_rates", on_delete: :restrict
  add_foreign_key "invoices", "business_entities", column: "secondary_entity_id", on_delete: :restrict
  add_foreign_key "invoices", "business_entity_locations", column: "primary_location_id", on_delete: :restrict
  add_foreign_key "invoices", "currencies", on_delete: :restrict
  add_foreign_key "invoices", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "invoices", "voucher_sequences", on_delete: :restrict
  add_foreign_key "order_line_items", "orders", on_delete: :restrict
  add_foreign_key "order_line_items", "products", on_delete: :restrict
  add_foreign_key "orders", "currencies", on_delete: :restrict
  add_foreign_key "orders", "users", column: "booked_by_id", on_delete: :restrict
  add_foreign_key "products", "authors", on_delete: :restrict
  add_foreign_key "products", "categories", on_delete: :restrict
  add_foreign_key "products", "core_levels", on_delete: :restrict
  add_foreign_key "products", "distribution_types", on_delete: :restrict
  add_foreign_key "products", "languages", on_delete: :restrict
  add_foreign_key "products", "product_groups", on_delete: :restrict
  add_foreign_key "products", "publishers", on_delete: :restrict
  add_foreign_key "products", "uoms", on_delete: :restrict
  add_foreign_key "publishers", "business_entities", on_delete: :restrict
  add_foreign_key "regions", "currencies", on_delete: :restrict
  add_foreign_key "state_category_tax_rates", "categories", on_delete: :restrict
  add_foreign_key "state_category_tax_rates", "states", on_delete: :restrict
  add_foreign_key "states", "regions", on_delete: :restrict
  add_foreign_key "user_roles", "business_entities", on_delete: :restrict
  add_foreign_key "user_roles", "business_entity_locations", on_delete: :restrict
  add_foreign_key "user_roles", "roles", on_delete: :restrict
  add_foreign_key "user_roles", "users", on_delete: :restrict
  add_foreign_key "users", "accounts", column: "cash_account_id", on_delete: :restrict
  add_foreign_key "users", "cities", on_delete: :restrict
  add_foreign_key "voucher_sequences", "business_entities", on_delete: :restrict
  add_foreign_key "zones", "regions", on_delete: :restrict
end
