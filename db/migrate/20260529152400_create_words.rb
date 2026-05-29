class CreateWords < ActiveRecord::Migration[8.0]
  def change
    create_table :words do |t|
      t.references :language, null: false, foreign_key: true
      t.string :word_type, null: false
      t.string :lemma, null: false
      t.string :part_of_speech
      t.string :article
      t.string :gender
      t.integer :frequency_rank
      t.string :level
      t.references :theme, foreign_key: true
      # null = curated/shared; set = private user-added word
      t.integer :owner_user_id
      t.timestamps
    end

    add_check_constraint :words,
      "word_type IN ('word', 'phrase')",
      name: "chk_words_word_type"

    add_index :words, :owner_user_id
    add_index :words, [:language_id, :frequency_rank]
    add_index :words, [:language_id, :owner_user_id]
    add_foreign_key :words, :users, column: :owner_user_id
  end
end
