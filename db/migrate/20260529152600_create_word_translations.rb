class CreateWordTranslations < ActiveRecord::Migration[8.0]
  def change
    create_table :word_translations do |t|
      t.references :word, null: false, foreign_key: true
      t.references :language, null: false, foreign_key: true
      t.text :meaning, null: false
      t.text :notes
    end

    add_index :word_translations, [:word_id, :language_id], unique: true
  end
end
