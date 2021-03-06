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

ActiveRecord::Schema.define(version: 20170319142539) do

  create_table "event_detail_topics", force: true do |t|
    t.integer  "event_detail_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_details", force: true do |t|
    t.string   "detail"
    t.string   "detail_for_index"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_details", ["detail_for_index"], name: "index_event_details_on_detail_for_index", using: :btree

  create_table "events", force: true do |t|
    t.string   "name"
    t.string   "name_for_index"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["name_for_index"], name: "index_events_on_name_for_index", using: :btree

  create_table "topics", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
