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

ActiveRecord::Schema[8.0].define(version: 2026_05_29_153100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companions", force: :cascade do |t|
    t.bigint "language_id", null: false
    t.string "name", null: false
    t.string "species", null: false
    t.text "persona", null: false
    t.index ["language_id"], name: "index_companions_on_language_id", unique: true
  end

  create_table "daily_activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "language_id", null: false
    t.date "activity_date", null: false
    t.boolean "module_completed", default: false, null: false
    t.integer "new_words_introduced", default: 0, null: false
    t.integer "cards_reviewed", default: 0, null: false
    t.integer "flashcards_done", default: 0, null: false
    t.integer "speaking_done", default: 0, null: false
    t.integer "listening_done", default: 0, null: false
    t.integer "reading_done", default: 0, null: false
    t.index ["activity_date"], name: "index_daily_activities_on_activity_date"
    t.index ["language_id"], name: "index_daily_activities_on_language_id"
    t.index ["user_id", "language_id", "activity_date"], name: "idx_on_user_id_language_id_activity_date_dcdb63bf93", unique: true
    t.index ["user_id"], name: "index_daily_activities_on_user_id"
  end

  create_table "fsrs_cards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "word_id", null: false
    t.string "card_type", null: false
    t.float "stability"
    t.float "difficulty"
    t.string "state", default: "new", null: false
    t.integer "reps", default: 0, null: false
    t.integer "lapses", default: 0, null: false
    t.integer "scheduled_days", default: 0, null: false
    t.datetime "due_at"
    t.datetime "last_reviewed_at"
    t.index ["due_at"], name: "index_fsrs_cards_on_due_at"
    t.index ["user_id", "word_id", "card_type"], name: "index_fsrs_cards_on_user_id_and_word_id_and_card_type", unique: true
    t.index ["user_id"], name: "index_fsrs_cards_on_user_id"
    t.index ["word_id"], name: "index_fsrs_cards_on_word_id"
    t.check_constraint "card_type::text = ANY (ARRAY['recognition'::character varying, 'production'::character varying]::text[])", name: "chk_fsrs_cards_card_type"
    t.check_constraint "state::text = ANY (ARRAY['new'::character varying, 'learning'::character varying, 'review'::character varying, 'relearning'::character varying]::text[])", name: "chk_fsrs_cards_state"
  end

  create_table "grammar_references", force: :cascade do |t|
    t.bigint "language_id", null: false
    t.string "title", null: false
    t.string "category", null: false
    t.text "content", null: false
    t.integer "display_order", default: 0, null: false
    t.index ["language_id", "category"], name: "index_grammar_references_on_language_id_and_category"
    t.index ["language_id", "display_order"], name: "index_grammar_references_on_language_id_and_display_order"
    t.index ["language_id"], name: "index_grammar_references_on_language_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.boolean "is_learnable", default: false, null: false
    t.index ["code"], name: "index_languages_on_code", unique: true
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "themes", force: :cascade do |t|
    t.bigint "language_id", null: false
    t.string "name", null: false
    t.integer "display_order", default: 0, null: false
    t.index ["language_id", "name"], name: "index_themes_on_language_id_and_name", unique: true
    t.index ["language_id"], name: "index_themes_on_language_id"
  end

  create_table "user_languages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "language_id", null: false
    t.integer "current_streak", default: 0, null: false
    t.integer "longest_streak", default: 0, null: false
    t.date "last_studied_on"
    t.integer "words_introduced", default: 0, null: false
    t.datetime "started_at", null: false
    t.index ["language_id"], name: "index_user_languages_on_language_id"
    t.index ["user_id", "language_id"], name: "index_user_languages_on_user_id_and_language_id", unique: true
    t.index ["user_id"], name: "index_user_languages_on_user_id"
  end

  create_table "user_vocabulary", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "word_id", null: false
    t.bigint "language_id", null: false
    t.string "entry_source", null: false
    t.date "introduced_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_user_vocabulary_on_language_id"
    t.index ["user_id", "word_id"], name: "index_user_vocabulary_on_user_id_and_word_id", unique: true
    t.index ["user_id"], name: "index_user_vocabulary_on_user_id"
    t.index ["word_id"], name: "index_user_vocabulary_on_word_id"
    t.check_constraint "entry_source::text = ANY (ARRAY['curriculum'::character varying, 'user_added'::character varying]::text[])", name: "chk_user_vocabulary_entry_source"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "base_language_id"
    t.integer "active_language_id"
    t.integer "current_streak", default: 0, null: false
    t.integer "longest_streak", default: 0, null: false
    t.date "last_active_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_language_id"], name: "index_users_on_active_language_id"
    t.index ["base_language_id"], name: "index_users_on_base_language_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "word_forms", force: :cascade do |t|
    t.bigint "word_id", null: false
    t.string "form_text", null: false
    t.string "morphology"
    t.boolean "is_primary", default: false, null: false
    t.index ["word_id", "is_primary"], name: "index_word_forms_on_word_id_and_is_primary"
    t.index ["word_id"], name: "index_word_forms_on_word_id"
  end

  create_table "word_translations", force: :cascade do |t|
    t.bigint "word_id", null: false
    t.bigint "language_id", null: false
    t.text "meaning", null: false
    t.text "notes"
    t.index ["language_id"], name: "index_word_translations_on_language_id"
    t.index ["word_id", "language_id"], name: "index_word_translations_on_word_id_and_language_id", unique: true
    t.index ["word_id"], name: "index_word_translations_on_word_id"
  end

  create_table "words", force: :cascade do |t|
    t.bigint "language_id", null: false
    t.string "word_type", null: false
    t.string "lemma", null: false
    t.string "part_of_speech"
    t.string "article"
    t.string "gender"
    t.integer "frequency_rank"
    t.string "level"
    t.bigint "theme_id"
    t.integer "owner_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id", "frequency_rank"], name: "index_words_on_language_id_and_frequency_rank"
    t.index ["language_id", "owner_user_id"], name: "index_words_on_language_id_and_owner_user_id"
    t.index ["language_id"], name: "index_words_on_language_id"
    t.index ["owner_user_id"], name: "index_words_on_owner_user_id"
    t.index ["theme_id"], name: "index_words_on_theme_id"
    t.check_constraint "word_type::text = ANY (ARRAY['word'::character varying, 'phrase'::character varying]::text[])", name: "chk_words_word_type"
  end

  add_foreign_key "companions", "languages"
  add_foreign_key "daily_activities", "languages"
  add_foreign_key "daily_activities", "users"
  add_foreign_key "fsrs_cards", "users"
  add_foreign_key "fsrs_cards", "words"
  add_foreign_key "grammar_references", "languages"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "themes", "languages"
  add_foreign_key "user_languages", "languages"
  add_foreign_key "user_languages", "users"
  add_foreign_key "user_vocabulary", "languages"
  add_foreign_key "user_vocabulary", "users"
  add_foreign_key "user_vocabulary", "words"
  add_foreign_key "users", "languages", column: "active_language_id"
  add_foreign_key "users", "languages", column: "base_language_id"
  add_foreign_key "word_forms", "words"
  add_foreign_key "word_translations", "languages"
  add_foreign_key "word_translations", "words"
  add_foreign_key "words", "languages"
  add_foreign_key "words", "themes"
  add_foreign_key "words", "users", column: "owner_user_id"
end
