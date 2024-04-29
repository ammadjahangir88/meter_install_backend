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

ActiveRecord::Schema[7.1].define(version: 2024_04_28_151945) do
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

  create_table "meters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "NEW_METER_NUMBER", null: false
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
    t.boolean "QC_CHECK", default: false
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
    t.index ["NEW_METER_NUMBER"], name: "index_meters_on_NEW_METER_NUMBER", unique: true
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

  add_foreign_key "divisions", "regions"
  add_foreign_key "meters", "subdivisions"
  add_foreign_key "meters", "users"
  add_foreign_key "regions", "discos"
  add_foreign_key "subdivisions", "divisions"
end
