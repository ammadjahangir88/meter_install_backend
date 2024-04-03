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

ActiveRecord::Schema[7.1].define(version: 2024_04_03_122656) do
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
    t.string "reference_no", null: false
    t.string "status"
    t.string "old_meter_no"
    t.float "old_meter_reading"
    t.float "new_meter_reading"
    t.string "connection_type"
    t.date "bill_month"
    t.float "longitude"
    t.float "latitude"
    t.string "meter_type"
    t.float "kwh_mf"
    t.float "sanction_load"
    t.string "full_name"
    t.text "address"
    t.boolean "qc_check", default: false
    t.bigint "subdivision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "APPLICATION_NO"
    t.string "GREEN_METER"
    t.string "TELCO"
    t.string "SIM_NO"
    t.string "SIGNAL_STRENGTH"
    t.string "PICTURE_UPLOAD"
    t.index ["subdivision_id"], name: "index_meters_on_subdivision_id"
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
  add_foreign_key "regions", "discos"
  add_foreign_key "subdivisions", "divisions"
end
