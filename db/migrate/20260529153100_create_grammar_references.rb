class CreateGrammarReferences < ActiveRecord::Migration[8.0]
  def change
    create_table :grammar_references do |t|
      t.references :language, null: false, foreign_key: true
      t.string :title, null: false
      t.string :category, null: false
      t.text :content, null: false
      t.integer :display_order, null: false, default: 0
    end

    add_index :grammar_references, [:language_id, :category]
    add_index :grammar_references, [:language_id, :display_order]
  end
end
