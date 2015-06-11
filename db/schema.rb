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

ActiveRecord::Schema.define(version: 20150604025212) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coreentities", id: false, force: true do |t|
    t.text "aid"
    t.text "core_entities"
  end

  create_table "coverages", id: false, force: true do |t|
    t.string   "aid",        null: false
    t.decimal  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "details", id: false, force: true do |t|
    t.string   "aid",        null: false
    t.decimal  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histories", force: true do |t|
    t.string   "aid",        null: false
    t.string   "uuid",       null: false
    t.integer  "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "middle_scores", id: false, force: true do |t|
    t.string   "aid",        null: false
    t.text     "entity",     null: false
    t.text     "polarity",   null: false
    t.text     "core",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsarticles", id: false, force: true do |t|
    t.text "aid",      null: false
    t.text "title"
    t.text "summary"
    t.text "link"
    t.text "text"
    t.text "media"
    t.text "image"
    t.text "pid"
    t.text "category"
    t.text "pubdate"
  end

  create_table "polarities", id: false, force: true do |t|
    t.string   "aid",        null: false
    t.decimal  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "polarity_scores", id: false, force: true do |t|
    t.string   "aid"
    t.text     "p_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topic_scores", id: false, force: true do |t|
    t.string   "aid",        null: false
    t.text     "entity",     null: false
    t.text     "topic",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topic_scores", ["aid", "entity"], name: "index_topic_scores_on_aid_and_entity", unique: true, using: :btree

  create_table "user_scores", id: false, force: true do |t|
    t.string   "aid",        null: false
    t.string   "uuid",       null: false
    t.text     "link"
    t.decimal  "p_score"
    t.decimal  "c_score"
    t.decimal  "d_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uuid_tables", id: false, force: true do |t|
    t.string   "uuid",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "uuid_tables", ["uuid"], name: "uuid", unique: true, using: :btree

end
