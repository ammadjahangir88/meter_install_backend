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

ActiveRecord::Schema[7.1].define(version: 2024_06_10_091757) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "discos", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "divisions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id"], name: "index_divisions_on_region_id"
  end

  create_table "inspections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "meter_id", null: false
    t.bigint "user_id", null: false
    t.boolean "meter_type_ok"
    t.boolean "display_verification_ok"
    t.boolean "installation_location_ok"
    t.boolean "wiring_connection_ok"
    t.boolean "sealing_ok"
    t.boolean "documentation_ok"
    t.boolean "compliance_assurance_ok"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meter_id"], name: "index_inspections_on_meter_id"
    t.index ["user_id"], name: "index_inspections_on_user_id"
  end

  create_table "meters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "NEW_METER_NUMBER"
    t.string "REF_NO", null: false
    t.string "METER_STATUS"
    t.string "OLD_METER_NUMBER"
    t.float "OLD_METER_READING"
    t.float "NEW_METER_READING"
    t.string "CONNECTION_TYPE"
    t.date "BILL_MONTH"
    t.float "LONGITUDE"
    t.float "LATITUDE"
    t.string "METER_TYPE"
    t.float "KWH_MF"
    t.float "SAN_LOAD"
    t.string "CONSUMER_NAME"
    t.text "CONSUMER_ADDRESS"
    t.string "APPLICATION_NO"
    t.string "GREEN_METER"
    t.string "TELCO"
    t.string "SIM_NO"
    t.string "SIGNAL_STRENGTH"
    t.string "PICTURE_UPLOAD"
    t.datetime "METR_REPLACE_DATE_TIME"
    t.integer "NO_OF_RESET_OLD_METER"
    t.integer "NO_OF_RESET_NEW_METER"
    t.float "KWH_T1"
    t.float "KWH_T2"
    t.float "KWH_TOTAL"
    t.float "KVARH_T1"
    t.float "KVARH_T2"
    t.float "KVARH_TOTAL"
    t.float "MDI_T1"
    t.float "MDI_T2"
    t.float "MDI_TOTAL"
    t.float "CUMULATIVE_MDI_T1"
    t.float "CUMULATIVE_MDI_T2"
    t.float "CUMULATIVE_MDI_Total"
    t.bigint "subdivision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["REF_NO"], name: "index_meters_on_REF_NO", unique: true
    t.index ["subdivision_id"], name: "index_meters_on_subdivision_id"
    t.index ["user_id"], name: "index_meters_on_user_id"
  end

  create_table "regions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "disco_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disco_id"], name: "index_regions_on_disco_id"
  end

  create_table "subdivisions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "division_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["division_id"], name: "index_subdivisions_on_division_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "role", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "divisions", "regions"
  add_foreign_key "inspections", "meters"
  add_foreign_key "inspections", "users"
  add_foreign_key "meters", "subdivisions"
  add_foreign_key "meters", "users"
  add_foreign_key "regions", "discos"
  add_foreign_key "subdivisions", "divisions"
end
