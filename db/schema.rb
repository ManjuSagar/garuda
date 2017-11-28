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

ActiveRecord::Schema.define(version: 20161201160248) do

  create_table "customers", force: true do |t|
    t.string  "name",                    null: false
    t.string  "mobile"
    t.string  "email",      default: ""
    t.string  "address"
    t.string  "occupation"
    t.string  "gender"
    t.integer "age"
    t.string  "remarks",    default: ""
  end

  add_index "customers", ["mobile"], name: "index_customers_on_mobile", unique: true, using: :btree

  create_table "stores", force: true do |t|
    t.string "name", null: false
  end

  add_index "stores", ["name"], name: "index_stores_on_name", unique: true, using: :btree

  create_table "transaction_items", force: true do |t|
    t.integer "transaction_id",   null: false
    t.string  "item_id",          null: false
    t.integer "store_id",         null: false
    t.integer "amount",           null: false
    t.date    "date",             null: false
    t.boolean "is_jwells"
    t.integer "items_count"
    t.string  "item_wise_amount"
  end

  add_index "transaction_items", ["item_id", "store_id"], name: "index_transaction_items_on_item_id_and_store_id", unique: true, using: :btree

  create_table "transactions", force: true do |t|
    t.datetime "date",                    null: false
    t.integer  "customer_id"
    t.string   "winner_doc_file_name"
    t.string   "winner_doc_content_type"
    t.integer  "winner_doc_file_size"
    t.datetime "winner_doc_updated_at"
    t.integer  "coupon_amount",           null: false
  end

  create_table "users", force: true do |t|
    t.string   "email",               default: "",         null: false
    t.string   "encrypted_password",  default: "",         null: false
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "role",                default: "operator", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "voucher_masters", force: true do |t|
    t.string "barcode_number", null: false
    t.string "serial"
    t.string "book"
  end

  add_index "voucher_masters", ["barcode_number"], name: "index_voucher_masters_on_barcode_number", unique: true, using: :btree

  create_table "vouchers", force: true do |t|
    t.string  "barcode_number", null: false
    t.integer "transaction_id", null: false
    t.boolean "winner"
    t.date    "win_date"
  end

  add_index "vouchers", ["barcode_number"], name: "index_vouchers_on_barcode_number", unique: true, using: :btree
  add_index "vouchers", ["win_date"], name: "index_vouchers_on_win_date", unique: true, using: :btree

end
