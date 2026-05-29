class CreateUserLanguages < ActiveRecord::Migration[8.0]
  def change
    create_table :user_languages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :language, null: false, foreign_key: true
      t.integer :current_streak, null: false, default: 0
      t.integer :longest_streak, null: false, default: 0
      t.date :last_studied_on
      t.integer :words_introduced, null: false, default: 0
      t.datetime :started_at, null: false
    end

    add_index :user_languages, [:user_id, :language_id], unique: true
  end
end
