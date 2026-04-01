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

ActiveRecord::Schema[7.2].define(version: 2026_04_01_000001) do
  create_table "contestants", force: :cascade do |t|
    t.integer "season_id", null: false
    t.string "name", limit: 100, null: false
    t.integer "status", default: 0, null: false
    t.integer "eliminated_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tribe"
    t.text "previous_tribes"
    t.integer "tribe_from_week"
    t.index ["season_id", "name"], name: "index_contestants_on_season_id_and_name", unique: true
    t.index ["season_id"], name: "index_contestants_on_season_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_likes_on_message_id"
    t.index ["user_id", "message_id"], name: "index_likes_on_user_id_and_message_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "parent_id"
    t.text "body", null: false
    t.boolean "pinned", default: false, null: false
    t.boolean "anonymous", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_messages_on_parent_id"
    t.index ["pinned", "created_at"], name: "index_messages_on_pinned_and_created_at"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "participations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "season_id", null: false
    t.boolean "paid_in", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "auto_pick", default: false, null: false
    t.index ["season_id"], name: "index_participations_on_season_id"
    t.index ["user_id", "season_id"], name: "index_participations_on_user_id_and_season_id", unique: true
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "poll_options", force: :cascade do |t|
    t.integer "message_id", null: false
    t.string "label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_poll_options_on_message_id"
  end

  create_table "poll_votes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "poll_option_id", null: false
    t.integer "message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_option_id"], name: "index_poll_votes_on_poll_option_id"
    t.index ["user_id", "message_id"], name: "index_poll_votes_on_user_id_and_message_id", unique: true
    t.index ["user_id"], name: "index_poll_votes_on_user_id"
  end

  create_table "scoring_event_types", force: :cascade do |t|
    t.string "key", null: false
    t.string "label", null: false
    t.integer "points", default: 0, null: false
    t.boolean "is_elimination", default: false, null: false
    t.boolean "is_winner", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_scoring_event_types_on_key", unique: true
  end

  create_table "scoring_events", force: :cascade do |t|
    t.integer "contestant_id", null: false
    t.integer "week_id", null: false
    t.string "event_type", limit: 50, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contestant_id", "week_id", "event_type"], name: "idx_on_contestant_id_week_id_event_type_a55f56d112"
    t.index ["contestant_id"], name: "index_scoring_events_on_contestant_id"
    t.index ["week_id"], name: "index_scoring_events_on_week_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.integer "number", null: false
    t.integer "year", null: false
    t.integer "buy_in_cents", default: 1000
    t.integer "merge_week"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_seasons_on_number", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", limit: 100, null: false
    t.integer "role", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_board_visit_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weekly_picks", force: :cascade do |t|
    t.integer "participation_id", null: false
    t.integer "week_id", null: false
    t.integer "contestant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contestant_id"], name: "index_weekly_picks_on_contestant_id"
    t.index ["participation_id", "week_id"], name: "index_weekly_picks_on_participation_id_and_week_id", unique: true
    t.index ["participation_id"], name: "index_weekly_picks_on_participation_id"
    t.index ["week_id"], name: "index_weekly_picks_on_week_id"
  end

  create_table "weeks", force: :cascade do |t|
    t.integer "season_id", null: false
    t.integer "number", null: false
    t.date "air_date"
    t.datetime "picks_locked_at", null: false
    t.boolean "scored", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id", "number"], name: "index_weeks_on_season_id_and_number", unique: true
    t.index ["season_id"], name: "index_weeks_on_season_id"
  end

  create_table "winner_picks", force: :cascade do |t|
    t.integer "participation_id", null: false
    t.integer "contestant_id", null: false
    t.integer "week_locked", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contestant_id"], name: "index_winner_picks_on_contestant_id"
    t.index ["participation_id"], name: "index_winner_picks_on_participation_id", unique: true
  end

  add_foreign_key "contestants", "seasons"
  add_foreign_key "likes", "messages"
  add_foreign_key "likes", "users"
  add_foreign_key "messages", "users"
  add_foreign_key "participations", "seasons"
  add_foreign_key "participations", "users"
  add_foreign_key "poll_options", "messages"
  add_foreign_key "poll_votes", "messages"
  add_foreign_key "poll_votes", "poll_options"
  add_foreign_key "poll_votes", "users"
  add_foreign_key "scoring_events", "contestants"
  add_foreign_key "scoring_events", "weeks"
  add_foreign_key "weekly_picks", "contestants"
  add_foreign_key "weekly_picks", "participations"
  add_foreign_key "weekly_picks", "weeks"
  add_foreign_key "weeks", "seasons"
  add_foreign_key "winner_picks", "contestants"
  add_foreign_key "winner_picks", "participations"
end
