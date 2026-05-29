class CreateWordForms < ActiveRecord::Migration[8.0]
  def change
    create_table :word_forms do |t|
      t.references :word, null: false, foreign_key: true
      t.string :form_text, null: false
      t.string :morphology
      t.boolean :is_primary, null: false, default: false
    end

    add_index :word_forms, [:word_id, :is_primary]
  end
end
