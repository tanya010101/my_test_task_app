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

ActiveRecord::Schema[8.0].define(version: 2025_09_27_201131) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "formula_type", ["harris-benedict", "mifflin-st-jeor"]
  create_enum "formula_type_bmr", ["mifflin_santGeora", "harris_benedict"]
  create_enum "gender_enum", ["male", "female"]
  create_enum "roles", ["doctor", "patient"]

  create_table "doc_pat_relationships", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "doctor_id", null: false
  end

  create_table "doctors", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "middle_name"
  end

  create_table "patients", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "middle_name"
    t.date "date_of_birth", null: false
    t.float "height"
    t.float "weight"
    t.enum "gender", null: false, enum_type: "gender_enum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["first_name", "last_name", "middle_name", "date_of_birth"], name: "idx_on_first_name_last_name_middle_name_date_of_bir_0515768e99", unique: true
  end

  create_table "results_bmr", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.enum "formula_used", null: false, enum_type: "formula_type_bmr"
    t.decimal "result_value", precision: 10, scale: 2
    t.datetime "calculate_at", null: false
    t.index ["patient_id"], name: "index_results_bmr_on_patient_id"
  end

  add_foreign_key "doc_pat_relationships", "doctors", on_delete: :cascade
  add_foreign_key "doc_pat_relationships", "patients", on_delete: :cascade
  add_foreign_key "results_bmr", "patients", on_delete: :cascade
end
