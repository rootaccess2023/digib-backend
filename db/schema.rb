# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_04_14_224328) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "document_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "document_type", null: false
    t.string "purpose", null: false
    t.string "status", default: "pending"
    t.text "remarks"
    t.string "reference_number"
    t.decimal "fee_amount", precision: 8, scale: 2
    t.boolean "fee_paid", default: false
    t.jsonb "document_data"
    t.bigint "approved_by_id"
    t.datetime "approved_at"
    t.bigint "rejected_by_id"
    t.datetime "rejected_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_document_requests_on_approved_by_id"
    t.index ["document_type"], name: "index_document_requests_on_document_type"
    t.index ["reference_number"], name: "index_document_requests_on_reference_number", unique: true
    t.index ["rejected_by_id"], name: "index_document_requests_on_rejected_by_id"
    t.index ["status"], name: "index_document_requests_on_status"
    t.index ["user_id"], name: "index_document_requests_on_user_id"
  end

  create_table "jwt_blacklists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_blacklists_on_jti", unique: true
  end

  create_table "residential_addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "house_number"
    t.string "street_name"
    t.string "purok"
    t.string "barangay"
    t.string "city"
    t.string "province"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_residential_addresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.boolean "admin"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "name_extension"
    t.date "date_of_birth"
    t.string "gender"
    t.string "civil_status"
    t.string "mobile_phone"
    t.string "barangay_position"
    t.string "verification_status", default: "unverified"
    t.datetime "verified_at"
    t.bigint "verified_by_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["verified_by_id"], name: "index_users_on_verified_by_id"
  end

  add_foreign_key "document_requests", "users"
  add_foreign_key "document_requests", "users", column: "approved_by_id"
  add_foreign_key "document_requests", "users", column: "rejected_by_id"
  add_foreign_key "residential_addresses", "users"
end
