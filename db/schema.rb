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

ActiveRecord::Schema.define(version: 20150502091453) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coreentities", id: false, force: true do |t|
    t.text "aid"
    t.text "core_entities"
  end

  create_table "coverages", id: false, force: true do |t|
    t.string   "aid",        null: false
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "details", id: false, force: true do |t|
    t.string   "aid",        null: false
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsarticles", id: false, force: true do |t|
    t.string   "aid",        null: false
    t.string   "title"
    t.string   "image"
    t.string   "summary"
    t.string   "link"
    t.string   "text"
    t.string   "media"
    t.string   "pid"
    t.string   "pubDate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
  end

  create_table "polarities", id: false, force: true do |t|
    t.string   "aid",        null: false
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
