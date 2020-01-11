# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_07_234955) do

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "of", default: "message"
    t.integer "parent_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "message_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["message_id"], name: "index_events_on_message_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "subject", null: false
    t.integer "version", default: 1
    t.integer "category_id", null: false
    t.integer "user_id", null: false
    t.integer "paragraph_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_messages_on_category_id"
    t.index ["paragraph_id"], name: "index_messages_on_paragraph_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "paragraphs", force: :cascade do |t|
    t.integer "message_id", null: false
    t.integer "parent_id", null: false
    t.integer "next_id", null: false
    t.integer "user_id", null: false
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["message_id"], name: "index_paragraphs_on_message_id"
    t.index ["next_id"], name: "index_paragraphs_on_next_id"
    t.index ["parent_id"], name: "index_paragraphs_on_parent_id"
    t.index ["user_id"], name: "index_paragraphs_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "session_id"
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["id"], name: "index_sessions_on_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "tags", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "paragraph_id", null: false
    t.string "word", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["paragraph_id"], name: "index_tags_on_paragraph_id"
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
    t.string "email"
    t.string "crypted_password"
    t.string "salt"
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "categories", "parents"
  add_foreign_key "events", "messages"
  add_foreign_key "events", "users"
  add_foreign_key "messages", "categories"
  add_foreign_key "messages", "paragraphs"
  add_foreign_key "messages", "users"
  add_foreign_key "paragraphs", "messages"
  add_foreign_key "paragraphs", "nexts"
  add_foreign_key "paragraphs", "parents"
  add_foreign_key "paragraphs", "users"
  add_foreign_key "tags", "paragraphs"
  add_foreign_key "tags", "users"
end
