class CreateDailyActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :language, null: false, foreign_key: true
      t.date :activity_date, null: false
      t.boolean :module_completed, null: false, default: false
      t.integer :new_words_introduced, null: false, default: 0
      t.integer :cards_reviewed, null: false, default: 0
      t.integer :flashcards_done, null: false, default: 0
      t.integer :speaking_done, null: false, default: 0
      t.integer :listening_done, null: false, default: 0
      t.integer :reading_done, null: false, default: 0
    end

    add_index :daily_activities, [:user_id, :language_id, :activity_date], unique: true
    add_index :daily_activities, :activity_date
  end
end
