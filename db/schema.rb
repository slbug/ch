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

ActiveRecord::Schema.define(version: 20120921125437) do

  create_table "hotels", force: true do |t|
    t.string   "name",                       null: false
    t.boolean  "live",       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hotels", ["name"], name: "index_hotels_on_name"

  create_table "hotels_tags", id: false, force: true do |t|
    t.integer "hotel_id", null: false
    t.integer "tag_id",   null: false
  end

  add_index "hotels_tags", ["tag_id", "hotel_id"], name: "index_hotels_tags_on_tag_id_and_hotel_id"

  create_table "room_types", force: true do |t|
    t.string   "name",       null: false
    t.integer  "hotel_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "room_types", ["hotel_id"], name: "index_room_types_on_hotel_id"

  create_table "rule_bases", force: true do |t|
    t.integer   "conformable_id",                                                    null: false
    t.string    "conformable_type",                                                  null: false
    t.string    "type",                                                              null: false
    t.integer   "season_id"
    t.daterange "period",           default: -::Float::INFINITY...::Float::INFINITY, null: false
    t.datetime  "created_at"
    t.datetime  "updated_at"
  end

  add_index "rule_bases", ["conformable_id", "conformable_type"], name: "index_rule_bases_on_conformable_id_and_conformable_type"

  create_table "rule_properties", force: true do |t|
    t.integer  "rule_id",    null: false
    t.string   "name",       null: false
    t.string   "value",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rule_properties", ["rule_id", "name"], name: "index_rule_properties_on_rule_id_and_name"
  add_index "rule_properties", ["rule_id"], name: "index_rule_properties_on_rule_id"

  create_table "search_bases", force: true do |t|
    t.string    "where",                 null: false
    t.daterange "period",                null: false
    t.string    "uuid",       limit: 32, null: false
    t.datetime  "created_at"
    t.datetime  "updated_at"
  end

  add_index "search_bases", ["uuid"], name: "index_search_bases_on_uuid", unique: true

  create_table "search_rooms", force: true do |t|
    t.integer  "base_id",                   null: false
    t.integer  "adults_count", default: 2,  null: false
    t.integer  "children",     default: [], null: false, array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_rooms", ["base_id"], name: "index_search_rooms_on_base_id"

  create_table "seasons", force: true do |t|
    t.string    "name"
    t.daterange "period",     default: -::Float::INFINITY...::Float::INFINITY, null: false
    t.integer   "hotel_id",                                                    null: false
    t.datetime  "created_at"
    t.datetime  "updated_at"
  end

  add_index "seasons", ["hotel_id"], name: "index_seasons_on_hotel_id"

  create_table "tag_types", force: true do |t|
    t.string   "name",                   null: false
    t.integer  "priority",   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_types", ["name"], name: "index_tag_types_on_name", unique: true

  create_table "tags", force: true do |t|
    t.string   "name",                        null: false
    t.boolean  "live",        default: false, null: false
    t.integer  "tag_type_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name", "tag_type_id"], name: "index_tags_on_name_and_tag_type_id", unique: true
  add_index "tags", ["tag_type_id"], name: "index_tags_on_tag_type_id"

end
