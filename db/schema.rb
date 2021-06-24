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

ActiveRecord::Schema.define(version: 2018_11_13_203846) do

  create_table "links", force: :cascade do |t|
    t.integer "movie_id"
    t.integer "youtuber_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_links_on_movie_id"
    t.index ["youtuber_id"], name: "index_links_on_youtuber_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string "youtube_movie_id"
    t.integer "youtuber_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["youtube_movie_id"], name: "index_movies_on_youtube_movie_id", unique: true
    t.index ["youtuber_id"], name: "index_movies_on_youtuber_id"
  end

  create_table "offices", force: :cascade do |t|
    t.string "userlocal_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_offices_on_name"
    t.index ["userlocal_id"], name: "index_offices_on_userlocal_id"
  end

  create_table "youtubers", force: :cascade do |t|
    t.string "userlocal_id"
    t.string "youtube_id"
    t.string "name"
    t.integer "rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "office_id"
    t.index ["name"], name: "index_youtubers_on_name"
    t.index ["office_id"], name: "index_youtubers_on_office_id"
    t.index ["rank"], name: "index_youtubers_on_rank"
    t.index ["userlocal_id"], name: "index_youtubers_on_userlocal_id", unique: true
    t.index ["youtube_id"], name: "index_youtubers_on_youtube_id", unique: true
  end

end
