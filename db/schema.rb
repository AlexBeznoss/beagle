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

ActiveRecord::Schema[7.0].define(version: 2022_12_30_210014) do
  create_table "job_posts", force: :cascade do |t|
    t.string "pid", null: false
    t.integer "provider", null: false
    t.string "name", null: false
    t.string "url", null: false
    t.string "company"
    t.string "img_url"
    t.string "location"
    t.date "posted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "pid"], name: "index_job_posts_on_provider_and_pid", unique: true
  end
end
