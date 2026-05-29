class CreateUserVocabulary < ActiveRecord::Migration[8.0]
  def change
    create_table :user_vocabulary do |t|
      t.references :user, null: false, foreign_key: true
      t.references :word, null: false, foreign_key: true
      t.references :language, null: false, foreign_key: true
      t.string :entry_source, null: false
      t.date :introduced_on
      t.timestamps
    end

    add_index :user_vocabulary, [:user_id, :word_id], unique: true
    add_check_constraint :user_vocabulary,
      "entry_source IN ('curriculum', 'user_added')",
      name: "chk_user_vocabulary_entry_source"
  end
end
